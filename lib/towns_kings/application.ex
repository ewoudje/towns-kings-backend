defmodule TownsKings.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TownsKings.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TownsKings.PubSub}, #TODO how should we use this? (has redis option)
      {Redix, name: :redix}
    ]

    children = if Application.get_env(:towns_kings, :enable_faktroy, true) do
      [{FaktoryWorker, [
        connection: [
          host: Application.get_env(:towns_kings, :faktroy_host, "localhost"),
          port: Application.get_env(:towns_kings, :faktroy_port, 7419),
        ],
        worker_pool: [
          queues: [
            "mchigh",
            "mc",
            "mid",
            "mclow",
            "default", #INTERNAL
            "api",
            "low"
          ]
        ]
      ]},
        TownsKings.Repo.Minecraft.TickExec
      ] ++ children
    else
      children
    end

    children = if Application.get_env(:towns_kings, :enable_web, true) do
      [TownsKingsWeb.Endpoint | children]
    else
      children
    end


    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TownsKings.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TownsKingsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
