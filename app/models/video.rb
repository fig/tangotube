class Video < ApplicationRecord
  acts_as_votable

  include Filterable

  PERFORMANCE_REGEX=/(?<=\s|^|#)[1-8]\s?(of|de|\/|-)\s?[1-8](\s+$|)/.freeze

  validates :youtube_id, presence: true, uniqueness: true

  belongs_to :leader, optional: true, counter_cache: true
  belongs_to :follower, optional: true, counter_cache: true
  belongs_to :song, optional: true, counter_cache: true
  belongs_to :channel, optional: false, counter_cache: true
  belongs_to :event, optional: true, counter_cache: true

  scope :filter_by_orchestra, ->(song_artist, _user) { joins(:song).where("unaccent(songs.artist) ILIKE unaccent(?)", song_artist)}
  scope :filter_by_genre, ->(song_genre, _user) { joins(:song).where("unaccent(songs.genre) ILIKE unaccent(?)", song_genre) }
  scope :filter_by_leader, ->(leader, _user) { joins(:leader).where("unaccent(leaders.name) ILIKE unaccent(?)", leader) }
  scope :filter_by_follower, ->(follower, _user) { joins(:follower).where("unaccent(followers.name) ILIKE unaccent(?)", follower) }
  scope :filter_by_channel, ->(channel_id, _user) { joins(:channel).where("channels.channel_id ILIKE ?", channel_id) }
  scope :filter_by_event_id, ->(event_id, _user) { where(event_id: event_id) }
  scope :filter_by_song_id, ->(song_id, _user) { where(song_id: song_id) }
  scope :filter_by_hd, ->(boolean, _user) { where(hd: boolean) }
  scope :filter_by_year,->(year, _user) { where("extract(year from performance_date) = ?", year) }
  scope :filter_by_upload_year,->(year, _user) { where("extract(year from upload_date) = ?", year) }
  scope :hidden, -> { where(hidden: true) }
  scope :not_hidden, -> { where(hidden: false) }
  scope :paginate, ->(page, per_page) { offset(per_page * (page - 1)).limit(per_page) }

  # Active Admin scopes
  scope :has_song, -> { where.not(song_id: nil) }
  scope :has_leader, -> { where.not(leader_id: nil) }
  scope :has_follower, -> { where.not(follower_id: nil) }
  scope :missing_follower, -> { where(follower_id: nil) }
  scope :missing_leader, -> { where(leader_id: nil) }
  scope :missing_song, -> { where(song_id: nil) }

  # Youtube Music Scopes
  scope :scanned_youtube_music, -> { where(scanned_youtube_music: true) }
  scope :not_scanned_youtube_music, -> { where(scanned_youtube_music: false) }
  scope :has_youtube_song, -> { where.not(youtube_song: nil) }

  # AcrCloud Response scopes
  scope :successful_acrcloud, -> { where(acr_response_code: 0) }
  scope :not_successful_acrcloud, -> { where(acr_response_code: 1001) }
  scope :scanned_acrcloud, -> { where(acr_response_code: [0, 1001]) }
  scope :not_scanned_acrcloud,
        -> {
          where
            .not(acr_response_code: [0, 1001])
            .or(Video.where(acr_response_code: nil))
        }

  # Attribute Matching Scopes
  scope :with_song_title,
        lambda { |song_title|
          where(
            'unaccent(spotify_track_name) ILIKE unaccent(:song_title)
                                    OR unaccent(youtube_song) ILIKE unaccent(:song_title)
                                    OR unaccent(title) ILIKE unaccent(:song_title)
                                    OR unaccent(description) ILIKE unaccent(:song_title)
                                    OR unaccent(tags) ILIKE unaccent(:song_title)
                                    OR unaccent(acr_cloud_track_name) ILIKE unaccent(:song_title)',
            song_title: "%#{song_title}%"
          )
        }

  scope :with_song_artist_keyword,
        lambda { |song_artist_keyword|
          where(
            'spotify_artist_name ILIKE :song_artist_keyword
                                            OR unaccent(spotify_artist_name_2) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(youtube_artist) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(description) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(title) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(tags) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(spotify_album_name) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(acr_cloud_album_name) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(acr_cloud_artist_name) ILIKE unaccent(:song_artist_keyword)
                                            OR unaccent(acr_cloud_artist_name_1) ILIKE unaccent(:song_artist_keyword)',
            song_artist_keyword: "%#{song_artist_keyword}%"
          )
        }

  scope :with_dancer_name_in_title,
        lambda { |dancer_name|
          where(
            "unaccent(title) ILIKE unaccent(:dancer_name)",
            dancer_name: "%#{dancer_name}%"
          )
        }

  # Combined Scopes

  scope :title_match_missing_leader,
        ->(leader_name) {
          missing_leader.with_dancer_name_in_title(leader_name)
        }
  scope :title_match_missing_follower,
        ->(follower_name) {
          missing_follower.with_dancer_name_in_title(follower_name)
        }

  class << self

    def filter_by_watched(boolean, user)
      case boolean
      when "true"
        where(id: Ahoy::Event.viewed_by_user(user))
      when "false"
        where.not(id: Ahoy::Event.viewed_by_user(user))
      end
    end

    def filter_by_liked(boolean, user)
      case boolean
      when "true"
        where(id: user.find_up_voted_items.map(&:id))
      when "false"
        where(id: user.find_up_downsvoted_items.map(&:id))
      end
    end

    # Filters videos by the results from the materialized
    # full text search out of from VideosSearch
    def filter_by_query(query, _user)
      where(id: VideosSearch.search(query_without_stop_words(query)).select(:video_id))
    end

    def stop_words
      %w[and or the a an of to y e &]
    end

    def stop_words_regex
      /\b(#{stop_words.map { |word| Regexp.escape(word) }.join('|')})\b/
    end

    def query_without_stop_words(query)
      query.gsub(stop_words_regex, "").gsub("'", "").split.map(&:strip).join(" ")
    end

    def most_viewed_videos_by_month
      where( youtube_id: Ahoy::Event.most_viewed_videos_by_month)
    end
  end

  def grep_title_leader_follower

    self.leader = Leader.all.find { |leader| title.parameterize.match(leader.name.parameterize) }
    self.follower = Follower.all.find { |follower| title.parameterize.match(follower.name.parameterize) }
    save

  end

  def grep_performance_number
    array = Array.new
    array << title if title.present?
    array << description if description.present?
    search_string = array.join(" ")
    return unless search_string.match?(PERFORMANCE_REGEX)
    performance_array = search_string.match(PERFORMANCE_REGEX)[0].tr("^0-9", " ").split(" ").map(&:to_i)
    return if performance_array.empty?
    return if performance_array.first > performance_array.second || performance_array.second == 1
    self.performance_number = performance_array.first
    self.performance_total_number = performance_array.second
    save
  end

  def grep_title_description_acr_cloud_song

    array = Array.new
    array << title if title.present?
    array << description if description.present?
    array << spotify_artist_name if spotify_artist_name.present?
    array << spotify_artist_name_2 if spotify_artist_name_2.present?
    array << spotify_track_name if spotify_track_name.present?
    array << spotify_album_name if spotify_album_name.present?
    array << acr_cloud_artist_name if acr_cloud_artist_name.present?
    array << acr_cloud_artist_name_1 if acr_cloud_artist_name_1.present?
    array << acr_cloud_track_name if acr_cloud_track_name.present?
    array << acr_cloud_album_name if acr_cloud_album_name.present?
    array << youtube_song if youtube_song.present?
    array << youtube_artist if youtube_artist.present?
    search_string = array.join(" ")

    self.song = Song.filter_by_active
                    .find_all { |song| search_string.parameterize.match(song.title.parameterize)}
                    .find { |song| search_string.parameterize.match(song.last_name_search.parameterize)}
    save

  end

  def display
    @display ||= Video::Display.new(self)
  end

  def clicked!
    increment(:click_count)
    increment(:popularity)
    save!
  end
end
