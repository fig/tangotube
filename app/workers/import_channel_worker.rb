class ImportChannelWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  sidekiq_options queue: :default, retry: 3

  sidekiq_throttle(
    # Allow maximum 10 concurrent jobs of this class at a time.
    concurrency: { limit: 5 },
    # Allow maximum 1K jobs being processed within one hour window.
    # threshold: { limit: 1_000, period: 1.hour }
  )

  def perform(channel_id)
    Video::YoutubeImport.from_channel(channel_id)
  end
end
