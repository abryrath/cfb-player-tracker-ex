defmodule Crawler.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %{url: ""}}
  end

  def handle_call({:player, url}, _from, state) do
    IO.puts("process #{inspect self()} processing URL: #{url}")
    Process.sleep(1000)
    {:reply, :ok, %{state | url: url}}
  end
end
