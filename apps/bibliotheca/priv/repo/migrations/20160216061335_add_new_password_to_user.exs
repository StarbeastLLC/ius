defmodule Bibliotheca.Repo.Migrations.AddNewPasswordToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :new_password, :string
    end
  end
end
