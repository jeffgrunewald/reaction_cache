use Mix.Config

config :reaction_cache, ReactionCacheWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jwMxFBVql0mbmbjftlk+dsjbZlNo+jQCD76J/4nnsuONf5hGESAPHOVICiquU9wI",
  render_errors: [view: ReactionCacheWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ReactionCache.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
