defmodule PTracker.University do
  use Ecto.Schema
  import Ecto.Changeset

  schema "universities" do
    field :title

    many_to_many :players, PTracker.Player, join_through: "player_universities"
  end

  def changeset(uni, params) do
    uni
    |> cast(params, [:title])
    |> validate_required([:title])
    |> validate_length(:title, min: 3)
    |> unique_constraint(:title)
  end
end
