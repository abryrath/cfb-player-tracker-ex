defmodule PTracker.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:position, :string)
    field(:number, :integer)

    belongs_to(:nfl_team, PTracker.NflTeam)
    many_to_many(:universities, PTracker.University, join_through: "player_universities")
  end

  def changeset(player, params) do
    player
    |> cast(params, [:first_name, :last_name, :position, :number])
    |> validate_required([:first_name, :last_name])
    # |> cast_assoc](:universities)
    # |> cast_assoc(:nfl_team)
    |> unique_constraint(:last_name, name: :players_first_name_last_name_index)
  end
end
