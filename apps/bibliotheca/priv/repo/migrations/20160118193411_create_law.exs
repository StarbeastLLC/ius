defmodule Bibliotheca.Repo.Migrations.CreateFederalLaw do
  use Ecto.Migration

  def change do
    create table(:federal_laws) do
      add :file_name,     :string
      add :name,          :string
      add :header,        :text
      add :reform_date,   :string
      add :original_text, :text
      add :articles,      :map
      add :contents,      :map

      timestamps
    end

    create table(:federal_articles) do
      add :federal_law_id, :integer
      add :article_number, :string
      add :article_body,   :text

      timestamps
    end

    # create index(:laws, [:articles], using: :gin)
  end
end
