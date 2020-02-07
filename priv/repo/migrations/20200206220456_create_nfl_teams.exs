defmodule PTracker.Repo.Migrations.CreateNflTeams do
  use Ecto.Migration

  def change do
    create table(:nfl_teams) do
      add :region, :string
      add :name, :string
      add :logo_img_url, :string
      add :primary_color, :string
      add :secondary_color, :string
    end
  end
end
