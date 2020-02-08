defmodule PTracker.Crawler do
  use Supervisor

  @num_workers 5

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    IO.puts "Starting #{__MODULE__}"
    children = [
      #  PTracker.Crawler.Registry, name: PTracker.Crawler.Registry},
      :poolboy.child_spec(:worker, poolboy_config()),
      # PTracker.Crawler.Starter
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: PTracker.Crawler.Worker,
      size: @num_workers,
      max_overflow: 2
    ]
  end
end
