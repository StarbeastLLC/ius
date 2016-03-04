defmodule Bibliotheca.Repo.Migrations.AddFederalLawArticleIndex do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX article_body_index ON federal_articles USING gin(to_tsvector('spanish',article_body));"
  end

  def down do
    execute "DROP INDEX article_body_index;"
  end
end