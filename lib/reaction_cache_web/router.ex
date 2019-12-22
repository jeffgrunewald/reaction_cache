defmodule ReactionCacheWeb.Router do
  use ReactionCacheWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ReactionCacheWeb do
    pipe_through :api
  end
end
