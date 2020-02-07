defmodule Crawler.Supervisor do
  use Supervisor

  @num_workers 5

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Crawler.Registry, name: Crawler.Registry},
      :poolboy.child_spec(:worker, poolboy_config()),
      Crawler.Starter
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: Crawler.Worker,
      size: @num_workers,
      max_overflow: 2
    ]
  end
end
