# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crypto_bot,
  ecto_repos: [CryptoBot.Repo]

# Configures the endpoint
config :crypto_bot, CryptoBotWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CryptoBotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CryptoBot.PubSub,
  live_view: [signing_salt: "0GIcUMkQ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :crypto_bot, CryptoBot.Mailer, adapter: Swoosh.Adapters.Local

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

# FB Messenger Token
config :crypto_bot,
  app_token: System.get_env("CRYPTO_TOKEN") || "015dbcba-0a32-487e-8395-d962c311c89b",
  fb_token: System.get_env("FB_MESSENGER_TOKEN") || "015dbcba-0a32-487e-8395-d962c311c89b",
  page_id: System.get_env("PAGE_ID") || "015dbcba-0a32-487e-8395-d962c311c89b",
  access_tokenn: System.get_env("ACCESS_TOKEN") || "015dbcba-0a32-487e-8395-d962c311c89b"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
