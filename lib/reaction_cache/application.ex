defmodule ReactionCache.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {ReactionCache, []},
      supervisor(ReactionCacheWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: ReactionCache.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ReactionCacheWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
