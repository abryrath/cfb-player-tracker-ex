defmodule PTracker.Crawler.Parser do
  import Floki

  def listing_next_page(doc) do
    result = find(doc, "a:fl-contains('next')")

    case result do
      [] -> false
      _ -> true
    end
  end

  def listing_player_pages(doc) do
    doc
    |> find("a[href^='/player/']")
    |> attribute("href")
  end

  def player_attributes(doc) do
    parts =
      doc
      |> find(".player-name")
      |> text()
      |> String.trim_trailing()
      |> String.split(" ")

    [first_name | tail] = parts
    last_name = Enum.join(tail, " ")
    %{first_name: first_name, last_name: last_name}
  end

  def player_university(doc) do
    [{_, _, children} | _] = get_player_info(doc)

    university =
      children
      |> Stream.map(&match_university(&1))
      |> Enum.filter(fn n -> n != "" end)
      |> List.first()

    %{title: university}
  end

  defp match_university({"p", [], [{"strong", [], ["College"]}, ": " <> university]}),
    do: university

  defp match_university(_), do: ""

  def get_player_info(doc) do
    find(doc, ".player-info")
  end

  def player_team(doc) do
    [{_, _, children} | _] = get_player_info(doc)

    # IO.inspect(children)

    team =
      children
      |> Stream.map(&match_team(&1))
      |> Enum.filter(fn n -> n != "" end)
      |> List.first()

    # IO.inspect(team)
    team
  end

  defp match_team({"p", [{"class", "player-team-links"}], team_link}) do
    [{"a", [{"href", _}, {"class", _}], [team]} | _] = team_link
    parts = String.split(team)
    count = Enum.count(parts)

    region =
      parts
      |> Stream.take(count - 1)
      |> Enum.join(" ")

    name =
      parts
      |> Stream.drop(count - 1)
      |> Stream.take(1)
      |> Enum.join(" ")

    # IO.inspect(team)
    %{region: region, name: name}
  end

  defp match_team(_), do: ""
end
