Sentry.init do |config|
  config.dsn = 'https://aed45b5d6929e5386c75caba2713327a@o4510611728629760.ingest.de.sentry.io/4510611729612880'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true
end