alias PTracker.{Repo, Player, University, NflTeam}
import Ecto.Changeset

defmodule PTracker.CsvLoader do
  @csv_folder "./priv/csv/"

  def load_file(file, team) do
    file
    |> file_name
    |> File.read!()
    |> String.split("\n")
    |> Stream.map(&parse_line(&1, team))
    |> Enum.each(fn changeset ->
      IO.inspect(changeset)

      case Repo.insert(changeset) do
        {:ok, c} -> IO.puts("Success")
        {:error, reasons} -> IO.inspect(reasons)
      end
    end)
  end

  defp parse_line(line, team) do
    parts = String.split(line, ",")

    name = get_name(Enum.at(parts, 1))
    [first | last] = name

    params = %{
      number: Enum.at(parts, 0),
      first_name: first,
      last_name: Enum.join(last, " "),
      position: Enum.at(parts, 3),
      universities: [%{
        title: Enum.at(parts, 8)
      }],
      nfl_team: %{
        name: team
      }
    }

    %Player{}
    |> cast(
      params,
      [:first_name, :last_name, :position, :number]
    )
    |> cast_assoc(:universities)#, params[:universities])
    |> cast_assoc(:nfl_team)#, params[:team])
  end

  defp get_name(nil), do: ["", ""]

  defp get_name(string) do
    string
    |> String.split("\\")
    |> Enum.at(0)
    |> String.split(" ")
  end

  defp file_name(file) do
    Path.join(@csv_folder, file)
  end
end
