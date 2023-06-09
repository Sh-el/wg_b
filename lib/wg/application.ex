defmodule Wg.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    config_request_limiter_server = Application.get_env(:wg, WgWeb.RequestLimiter.Server)

    children = [
      # Start the Telemetry supervisor
      WgWeb.Telemetry,
      # Start the Ecto repository
      Wg.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wg.PubSub},
      # Start the Endpoint (http/https)
      WgWeb.Endpoint,
      # Start a worker by calling: Wg.Worker.start_link(arg)
      # {Wg.Worker, arg}
      {WgWeb.RequestLimiter.Server, config_request_limiter_server[:max_reqs_per_min]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wg.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WgWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
