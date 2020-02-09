defmodule PTracker.Crawler.Worker do
  use GenServer
  alias PTracker.Crawler.Parser

  @base_url "https://www.nfl.com"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call({:player, url}, _from, state) do
    full_url = @base_url <> url
    IO.puts("process #{inspect self()} processing URL: #{full_url}")

    {:ok, resp} = HTTPoison.get(full_url, [], recv_timeout: 5000, follow_redirect: true)

    # file_name = (String.split(url, "/") |> List.last()) <> ".html"
    # IO.puts "Writing output to #{file_name}"
    # File.write!(file_name, inspect(resp))

    {:ok, doc} = Floki.parse_document(resp.body)

    player = Parser.player_attributes(doc)
    university = Parser.player_university(doc)
    nfl_team = Parser.player_team(doc)

    IO.inspect({player, university, nfl_team})
    # Process.sleep(1000)
    {:reply, :ok, state}
  end
end
