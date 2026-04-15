Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*" # This allows any local port to connect during development
    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end