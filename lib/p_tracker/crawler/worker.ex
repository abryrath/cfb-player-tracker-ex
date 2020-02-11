defmodule PTracker.Crawler.Worker do
  use GenServer
  alias PTracker.Crawler.Parser
  alias PTracker.{Repo, Player, NflTeam, University}
  import Ecto.Changeset

  @base_url "https://www.nfl.com"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call({:player, url}, _from, state) do
    full_url = @base_url <> url
    IO.puts("process #{inspect(self())} processing URL: #{full_url}")

    {:ok, resp} = HTTPoison.get(full_url, [], recv_timeout: 5000, follow_redirect: true)

    {:ok, doc} = Floki.parse_document(resp.body)

    university_data = Parser.player_university(doc)

    university_changeset =
      %University{}
      |> cast(university_data, [:title])

    university_struct =
      case Repo.get_by(University, title: university_data.title) do
        nil -> Repo.insert(university_changeset)
        structure -> structure
      end

    team_data = Parser.player_team(doc)

    team_changeset =
      %NflTeam{}
      |> cast(team_data, [:region, :name])

    nfl_struct =
      case Repo.get_by(NflTeam, name: team_data.name) do
        nil -> Repo.insert(team_changeset)
        structure -> structure
      end

    player_data = Parser.player_attributes(doc)

    result =
      %Player{}
      |> Player.changeset(player_data)
      |> put_assoc(:nfl_team, nfl_struct)
      |> put_assoc(:universities, [university_struct])
      |> Repo.insert_or_update()

    case result do
      {:ok, _s} -> IO.puts("added successfully")
      {:error, reason} -> IO.inspect(reason)
    end

    {:reply, :ok, state}
  end
end
