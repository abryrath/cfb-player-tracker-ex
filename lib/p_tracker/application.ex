defmodule PTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      PTracker.Repo,
      PTracker.Crawler.Manager,
      {Plug.Cowboy, scheme: :http, plug: PTracker.Api.Router, options: [port: 4001]}
      # Starts a worker by calling: PTracker.Worker.start_link(arg)
      # {PTracker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
