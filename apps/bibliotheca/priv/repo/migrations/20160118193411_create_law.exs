defmodule Bibliotheca.Repo.Migrations.CreateLaw do
  use Ecto.Migration

  def change do
    create table(:laws) do
      add :file_name,     :string
      add :name,          :string
      add :header,        :text
      add :reform_date,   :string
      add :original_text, :text
      add :articles,      :map
      add :contents,      :map

      timestamps
    end

    create index(:laws, [:articles], using: :gin)
  end
end
