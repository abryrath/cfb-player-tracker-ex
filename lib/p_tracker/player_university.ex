defmodule PTracker.PlayerUniversity do
  use Ecto.Schema

  schema "player_universities" do
    belongs_to :universities, PTracker.University
    belongs_to :players, PTracker.Player
  end
end
