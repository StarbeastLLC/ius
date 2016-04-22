# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :bibliotheca, Bibliotheca.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "tts6gZ22X4lhBPdAm6DdOKhUTou/5ecZLlgVTl5ZFaPo97rUSKRDUvQ5CZHELAUZ",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Bibliotheca.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Mailgun credentials
config :mailgun, 
  domain: "https://api.mailgun.net/v3/sandbox9ddf700296ad4bf0a817cedfe2a09d99.mailgun.org",
  key: "key-0c056f5ddfd814fe0e9a1b831c26b561"

# Configures Elegua
config :elegua,
  user_model: Bibliotheca.User,
  app_repo: Bibliotheca.Repo

# Adds FB to Uberauth
config :ueberauth, Ueberauth,
  providers: [
    facebook: {Ueberauth.Strategy.Facebook, []}
  ]

# Facebook keys
config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "489333437934185",
  client_secret: "b8387dda996be57c022cf7eaeadb7d9f"

# Facebook Application
config :facebook,
  app_id: 489333437934185 #TEST APP / Ask Zura for credentials to add testers
  #app_id: 974600135936002

# Google Application
config :google,
  # Ask Zura for credentials
  client_id: "516881522852-m6p2l99r5110j7d0vasf8d1il6iqi4ts.apps.googleusercontent.com",
  client_secret: "Tq0KuC8ZB9h6ZXb1FEkPM3Bh"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
