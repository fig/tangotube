class VideosController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :authenticate_user!, only: %i[edit update]
  before_action :current_search, only: %i[index]
  before_action :set_video, only: %i[show edit update destroy upvote downvote]

  helper_method :sorting_params, :filtering_params

  def index
    @page = page
    @search =
      Video::Search.for(
        filtering_params: filtering_params,
        sorting_params: sorting_params,
        page: page,
        user: current_user
      )
    if sorting_params.empty? && page == 1 && @search.videos.size > 60 && (filtering_for_dancer? || dancer_name_match?)
        @search_most_recent =
        Video::Search.for(
          filtering_params: filtering_params,
          sorting_params: { direction: "desc", sort: "videos.performance_date" },
          page: page,
          user: current_user
        )

        @search_oldest =
        Video::Search.for(
          filtering_params: filtering_params,
          sorting_params: { direction: "asc", sort: "videos.performance_date" },
          page: page,
          user: current_user
        )

        @search_most_popular =
        Video::Search.for(
          filtering_params: filtering_params,
          sorting_params: { direction: "desc", sort: "videos.popularity" },
          page: page,
          user: current_user
        )
        if current_user.present?
          @search_most_popular_new_to_you =
          Video::Search.for(
            filtering_params: filtering_params.merge(watched: "false"),
            sorting_params: { direction: "desc", sort: "videos.popularity" },
            page: page,
            user: current_user
          )

          @search_most_popular_watched =
          Video::Search.for(
            filtering_params: filtering_params.merge(watched: "true"),
            sorting_params: { direction: "desc", sort: "videos.popularity" },
            page: page,
            user: current_user
          )
        end
      end
  end

  def edit
    set_recommended_videos
  end

  def show
    if @video.present?
      UpdateVideoWorker.perform_async(@video.youtube_id)
    else
      Video::YoutubeImport.from_video(show_params[:v])
      @video = Video.find_by(youtube_id: show_params[:v])
    end
    set_recommended_videos
    @start_value = params[:start]
    @end_value = params[:end]
    @root_url = root_url
    @playback_speed = params[:speed] || "1"

    @comments =
      if params[:comment]
        @video.comments.includes([:commentable]).where(id: params[:comment])
      else
        @video.comments.includes([:commentable]).where(parent_id: nil)
      end
    @yt_comments = @video.yt_comments

    @video.clicked!
    ahoy.track("Video View", video_id: @video.id)
  end

  def update
    @video.update(video_params)
    redirect_to watch_path(v: @video.youtube_id)
  end

  def create
    @video = Video.create(youtube_id: params[:video][:youtube_id])
    fetch_new_video

    redirect_to root_path,
                notice:
                  "Video Sucessfully Added: The video must be approved before the videos are added"
  end

  def upvote
    if current_user.voted_up_on? @video
      @video.unvote_by current_user
    else
      @video.upvote_by current_user
    end
    render turbo_stream: turbo_stream.update("#{dom_id(@video)}_vote", partial: "videos/show/vote")
  end

  def downvote
    if current_user.voted_down_on? @video
      @video.unvote_by current_user
    else
      @video.downvote_by current_user
    end
    render turbo_stream: turbo_stream.update("#{dom_id(@video)}_vote", partial: "videos/show/vote")
  end

  private

  def set_video
    @video = Video
              .includes(:song, :leader, :follower, :event, :channel)
              .references(:song, :leader, :follower, :event, :channel)
              .find_by(youtube_id: show_params[:v]) if show_params[:v]
    @video = Video
              .includes(:song, :leader, :follower, :event, :channel)
              .references(:song, :leader, :follower, :event, :channel)
              .find(show_params[:id]) if show_params[:id]
  end

  def set_recommended_videos
    videos_from_this_performance
    videos_with_same_dancers
    videos_with_same_event
    videos_with_same_song
    videos_with_same_channel
  end

  def videos_from_this_performance
    @videos_from_this_performance = Video.includes(:song, :leader, :follower, :event, :channel)
                                         .references(:song, :leader, :follower, :event, :channel)
                                         .where("upload_date <= ?", @video.upload_date + 7.days)
                                         .where("upload_date >= ?", @video.upload_date - 7.days)
                                         .where(channel_id: @video.channel_id)
                                         .where(leader_id: @video.leader_id)
                                         .where(follower_id: @video.follower_id)
                                         .order("performance_number ASC")
                                         .where(hidden: false)
                                         .limit(8).load_async
  end

  def videos_with_same_dancers
    @videos_with_same_dancers = Video.includes(:song, :leader, :follower, :event, :channel)
                                         .references(:song, :leader, :follower, :event, :channel)
                                         .where("upload_date <= ?", @video.upload_date + 7.days)
                                         .where("upload_date >= ?", @video.upload_date - 7.days)
                                         .where(leader_id: @video.leader_id)
                                         .where(follower_id: @video.follower_id)
                                         .where(hidden: false)
                                         .limit(8).load_async
  end

  def videos_with_same_event
    @videos_with_same_event = Video.includes(:song, :leader, :follower, :event, :channel)
                                   .references(:song, :leader, :follower, :event, :channel)
                                   .where(event_id: @video.event_id)
                                   .where.not(event: nil)
                                   .where("upload_date <= ?", @video.upload_date + 7.days)
                                   .where("upload_date >= ?", @video.upload_date - 7.days)
                                   .where(hidden: false)
                                   .where.not(youtube_id: @video.youtube_id)
                                   .limit(16).load_async
    @videos_with_same_event -= @videos_from_this_performance
  end

  def videos_with_same_song
    @videos_with_same_song = Video.includes(:song, :leader, :follower, :event, :channel)
                                  .references(:song, :leader, :follower, :event, :channel)
                                  .where(song_id: @video.song_id)
                                  .has_leader.has_follower
                                  .where(hidden: false)
                                  .where.not(song_id: nil)
                                  .where.not(youtube_id: @video.youtube_id)
                                  .limit(8).load_async
  end

  def videos_with_same_channel
    @videos_with_same_channel = Video.includes(:song, :leader, :follower, :event, :channel)
                                  .references(:song, :leader, :follower, :event, :channel)
                                  .where(channel_id: @video.channel_id)
                                  .has_leader.has_follower
                                  .where(hidden: false)
                                  .where.not(youtube_id: @video.youtube_id)
                                  .limit(8).load_async
  end

  def current_search
    @current_search = params[:query]
  end

  def page
    @page ||= params.permit(:page).fetch(:page, 1).to_i
  end

  def video_params
    params
      .require(:video)
      .permit(:leader_id,
              :follower_id,
              :song_id,
              :event_id,
              :hidden,
              :"performance_date(1i)",
              :"performance_date(2i)",
              :"performance_date(3i)",
              :performance_number,
              :performance_total_number,
              :id)
  end

  def filtering_params
    params.permit(
      :leader,
      :follower,
      :channel,
      :genre,
      :orchestra,
      :song_id,
      :query,
      :hd,
      :event_id,
      :year,
      :watched,
      :liked
    )
  end

  def sorting_params
    params.permit(:direction, :sort)
  end

  def show_params
    params.permit(:v, :id)
  end

  def filtering_for_dancer?
    return true if filtering_params.include?(:leader) || filtering_params.include?(:follower)
  end

  def dancer_name_match?
    if filtering_params.fetch(:query, false).present?
      Leader.full_name_search(filtering_params.fetch(:query, false)) || Follower.full_name_search(filtering_params.fetch(:query, false))
    end
  end
end
