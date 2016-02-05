defmodule Bibliotheca.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :password, :string
      add :username, :string
      add :email, :string
      add :verification_token, :string
      add :is_verified, :boolean, default: false
      add :first_name, :string
      add :last_name, :string

      timestamps
    end

  end
end
