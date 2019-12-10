defmodule BloodstoneWeb.Router do
  use BloodstoneWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BloodstoneWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/*path", SidebarLive, session: [:path]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BloodstoneWeb do
  #   pipe_through :api
  # end
end
