# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :wg, WgWeb.RequestLimiter.Server, max_reqs_per_min: 30

config :wg,
  ecto_repos: [Wg.Repo]

# Configures the endpoint
config :wg, WgWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: WgWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Wg.PubSub,
  live_view: [signing_salt: "3zEh56hq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
