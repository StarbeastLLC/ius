defmodule Bibliotheca.Repo.Migrations.AddGoogleIdField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :google_id, :string
    end
  end
end
