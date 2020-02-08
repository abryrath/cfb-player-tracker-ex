defmodule PTracker.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :first_name, :string, null: true
      add :last_name, :string, null: false
      add :position, :string
      add :number, :integer
    end

    create index(:players, [:first_name, :last_name], unique: true)
  end
end
