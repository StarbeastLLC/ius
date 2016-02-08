defmodule Bibliotheca.Repo.Migrations.AddFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :state, :string
      add :accepts_terms, :boolean
      add :accepts_cookies, :boolean
      add :rfc, :string
      add :legal_name, :string
      add :legal_address, :string
      add :legal_email, :string
    end
  end
end
