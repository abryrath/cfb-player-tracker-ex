defmodule PTracker.Crawler.Manager do
  use GenServer

  @base_url "http://www.nfl.com/players/search?category={category}&filter={letter}&playerType=current"

  @links_dir "./persist/"

  @links_file "links.txt"
  ###
  # Client
  ###

  def start_link(_opts) do
    GenServer.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def crawl(letter \\ "A", page \\ 1) do
    IO.puts("#{__MODULE__}.crawl(_, #{letter}, #{page}")
    case GenServer.call(__MODULE__, {:crawl, {letter, page}}, 15000) do
      :next_letter -> crawl(next_letter(letter), 1)
      :next_page -> crawl(letter, page + 1)
      :complete ->
        write_links()
        IO.puts("Done")
    end
  end

  def write_links() do
    GenServer.cast(__MODULE__, {:write_links})
  end

  def read_links() do
    file_name = Path.join(@links_dir, @links_file)
    File.read!(file_name)
    |> String.split("\n")
  end

  def get_player_links do
    file_name = Path.join(@links_dir, @links_file)

    if not File.exists?(file_name) do
      crawl("A", 1)
    end

    read_links()
  end
  ###
  # Server
  ###

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:crawl, {letter, page}}, _from, player_links) do
    # Get the top level page
    url = alpha_listing_url(letter, page)
    resp = HTTPoison.get!(url, recv_timeout: 5000)

    {:ok, doc} = Floki.parse_document(resp.body)
    second_page = PTracker.Crawler.Parser.listing_next_page(doc)
    all_links = [PTracker.Crawler.Parser.listing_player_pages(doc) | player_links]
    all_links = List.flatten(all_links)

    if second_page do
      {:reply, :next_page, all_links}
    else
      next_letter = next_letter(letter)

      if next_letter == "" do
        {:reply, :complete, all_links}
      else
        {:reply, :next_letter, all_links}
      end
    end
  end

  @impl true
  def handle_cast({:write_links}, player_links) do
    output = Enum.join(player_links, "\n")

    File.mkdir_p!(@links_dir)

    @links_dir
    |> Path.join(@links_file)
    |> File.write!(output)

    {:noreply, player_links}
  end

  ###
  # Private
  ###

  defp alpha_listing_url(letter, page \\ 1, category \\ "lastName") do
    @base_url
    |> String.replace("{category}", category)
    |> String.replace("{letter}", letter)
    |> (fn str -> if page > 1, do: str <> "&d-447263-p=#{page}", else: str end).()
  end

  defp next_letter("Z"), do: ""

  defp next_letter(letter) when is_binary(letter) do
    <<i::utf8>> = letter
    <<i + 1::utf8>>
  end

  defp handle_response(%HTTPoison.Response{} = response) do
    IO.inspect(response)
  end
end
