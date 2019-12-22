use Mix.Config

config :reaction_cache, ReactionCacheWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
