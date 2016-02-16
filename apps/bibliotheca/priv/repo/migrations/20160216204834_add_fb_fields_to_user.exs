defmodule Bibliotheca.Repo.Migrations.AddFbFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :fb_id, :string
      add :fb_token, :string
    end
  end
end
