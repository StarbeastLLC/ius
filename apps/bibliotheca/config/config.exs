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

# Configures Elegua
config :elegua,
  user_model: Bibliotheca.User,
  app_repo: Bibliotheca.Repo,
  password_field: :password,
  username_field: :username,
  email_field: :email,
  verification_token_field: :verification_token,
  is_verified_field: :is_verified

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
