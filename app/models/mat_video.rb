class MatVideo < ApplicationRecord
  self.primary_key = :video_id

  include PgSearch::Model

  pg_search_scope( :search, against: :tsv_document,
                    using: {
                      tsearch: {
                        dictionary: 'english',
                        tsvector_column: 'tsv_document',
                        prefix: true
                      },
                    },
                    ignoring: :accents
                  )

  def self.refresh
    Scenic.database.refresh_materialized_view(:mat_videos, concurrently: false, cascade: false)
  end

    def readonly?
    true
  end
end