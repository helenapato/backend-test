import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :api_blogs, ApiBlogs.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "api_blogs_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :api_blogs, ApiBlogsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "1XUVyL56vhfbGebSZ+E2GJ4GHSIgs+sudhLdTK6sk1R1HKCzxF1EPs49/3N6id6p",
  server: false

# In test we don't send emails.
config :api_blogs, ApiBlogs.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
