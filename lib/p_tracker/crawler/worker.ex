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

    # file_name = (String.split(url, "/") |> List.last()) <> ".html"
    # IO.puts "Writing output to #{file_name}"
    # File.write!(file_name, inspect(resp))

    {:ok, doc} = Floki.parse_document(resp.body)

    player = Parser.player_attributes(doc)
    university = Parser.player_university(doc)
    nfl_team = Parser.player_team(doc)

    team_changeset = lookup_team(nfl_team)
    university_changeset = lookup_university(university)

    player =
      player
      |> Map.put(:universities, [university_changeset])
      |> Map.put(:nfl_team, team_changeset)

    _player_changeset = lookup_player(player)

    # IO.inspect({player, university, nfl_team})
    # Process.sleep(1000)
    {:reply, :ok, state}
  end

  def lookup_team(nil), do: %{}

  def lookup_team(team_data) do
    IO.puts("#{__MODULE__} lookup team: #{team_data.name}")

    case Repo.get_by(NflTeam, name: team_data.name) do
      nil ->
        # IO.puts "nil -> return team_data"
        team_data

      # %NflTeam{}
      # |> cast(team_data, [:region, :name])

      team ->
        # IO.puts "found a team: #{team.id}"
        # IO.inspect(team)
        Map.put(team_data, :id, team.id)
        # %{team_data | id: team.id}
    end
  end

  def lookup_university(university_data) do
    case Repo.get_by(University, title: university_data.title) do
      nil ->
        university_data

      # %University{}
      # |> cast(university_data, [:title])

      university ->
        Map.put(university_data, :id, university.id)
        # %{university_data | id: university.id}
    end
  end

  def lookup_player(player) do
    lookup =
      Repo.get_by(Player, first_name: player.first_name, last_name: player.last_name)
      |> Repo.preload([:universities, :nfl_team])

    IO.puts("#{__MODULE__} lookup_player - lookup: #{inspect(lookup)}")

    case lookup do
      nil ->
        IO.puts("lookup was nil, so inserting player")
        changeset = Player.changeset(%Player{}, player)
        IO.inspect(changeset)
        case Repo.insert(changeset) do
          {:ok, p} -> IO.puts "Success: #{inspect p}"
          _ -> "Error?"
        end

      p ->
        IO.puts("Found player: #{p.id}")
        Player.changeset(p, player)
        |> Repo.update()
    end
  end
end
