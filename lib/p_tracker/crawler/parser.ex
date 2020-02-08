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

  end
end
