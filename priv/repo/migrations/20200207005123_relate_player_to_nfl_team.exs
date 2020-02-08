defmodule PTracker.Repo.Migrations.RelatePlayerToNflTeam do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :nfl_team_id, references(:nfl_teams)
    end

    create index(:players, :nfl_team_id)
  end
end
