defmodule PTracker.Crawler.Manager do
  use GenServer

  @base_url "http://www.nfl.com/players/search?category={category}&filter={letter}&playerType=current"

  def alpha_listing_url(letter, page = 1, category = "lastName") do
    @base_url
    |> String.replace("{category}", category)
    |> String.replace("{letter}", letter)
    |> (fn str -> if page > 1, do: str <> "&d-447263-p=#{page}", else: str end).()
  end

  def init(_) do
    {:ok, %{parsed: []}}
  end
end
