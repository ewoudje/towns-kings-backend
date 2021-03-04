defmodule TownsKingsWeb.Router do
  use TownsKingsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
            schema: TownsKingsWeb.Schema

    forward "/", Absinthe.Plug,
            schema: TownsKingsWeb.Schema

  end

  # Other scopes may use custom stacks.
  # scope "/api", TownsKingsApiWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/", TownsKingsWeb do
      pipe_through :browser
      live_dashboard "/dev/dashboard", metrics: TownsKings.Telemetry
      forward "/", Plugs.StaticPlug
    end
  else
    scope "/", TownsKingsWeb do
      pipe_through :browser
      forward "/", Plugs.StaticPlug
    end

  end
end
