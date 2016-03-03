defmodule Bibliotheca.Repo.Migrations.AddSessionsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :sessions, {:array, :string}
    end
  end
end
