MeiliSearch::Rails.configuration = {
  meilisearch_host: ENV["ELASTICSEARCH_URL"] || "http://localhost:7700",
  timeout: 2,
  max_retries: 1
}
