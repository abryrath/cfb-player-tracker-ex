defmodule PTracker.Crawler.Player do
  @timeout 60_000

  def start(urls) do
    urls
    |> Enum.take(20)
    |> Enum.map(&async_call(&1))
    |> Enum.each(&await_and_store(&1))
  end
  def async_call(url) do
    Task.async(fn ->
      :poolboy.transaction(
        :worker,
        fn pid -> GenServer.call(pid, {:player, url}) end,
        @timeout
      )
    end)
  end

  def await_and_store(task) do
    task
    |> Task.await(@timeout)
    |> IO.inspect
  end
end
