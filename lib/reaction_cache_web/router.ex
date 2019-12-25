defmodule ReactionCacheWeb.Router do
  use ReactionCacheWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ReactionCacheWeb do
    pipe_through :api
    post "/reaction", ReactionController, :react
    get "/reaction_counts/:content_id", ReactionController, :get_counts
  end
end
