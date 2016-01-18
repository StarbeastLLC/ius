defmodule Bibliotheca.Repo.Migrations.CreateLaw do
  use Ecto.Migration

  def change do
    create table(:laws) do
      add :name, :string
      add :header, :string
      add :reform_date, :date
      add :original_text, :text
      add :json_text, :map

      timestamps
    end

    create index(:laws, [:json_text], using: :gin)
  end
end
