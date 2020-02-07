defmodule PTracker.NflTeam do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nfl_teams" do
    field(:region, :string)
    field(:name, :string)
    field(:logo_img_url, :string)
    field(:primary_color, :string)
    field(:secondary_color, :string)

    has_many(:players, PTracker.Player)
  end

  def changeset(team, params) do
    team
    |> cast(params, [:name, :region, :logo_img_url, :primary_color, :secondary_color])
    |> validate_required([:name])
  end
end
