defmodule PTracker.Repo.Migrations.CreatePlayerUniversities do
  use Ecto.Migration

  def change do
    create table(:player_universities) do
      add :player_id, references(:players)
      add :university_id, references(:universities)
    end

    create index(:player_universities, :player_id)
    create index(:player_universities, :university_id)
  end
end
