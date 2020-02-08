defmodule PTracker.Repo.Migrations.CreateUniversities do
  use Ecto.Migration

  def change do
    create table(:universities) do
      add :title, :string, null: false
    end

    create index("universities", [:title], unique: true)
  end
end
