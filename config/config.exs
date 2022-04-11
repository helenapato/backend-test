# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :api_blogs,
  ecto_repos: [ApiBlogs.Repo]

# Configures the endpoint
config :api_blogs, ApiBlogsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ApiBlogsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ApiBlogs.PubSub,
  live_view: [signing_salt: "2mPnL8V4"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :api_blogs, ApiBlogs.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

# Guardian config
config :api_blogs, ApiBlogs.Guardian,
       issuer: "api_blogs",
       secret_key: "yqa2m+ZFqiYqdnegreXyL1eWH8BKM+5niWEBt2aWKw0kXlcTeUAZV5RYvQ1x+II0"
