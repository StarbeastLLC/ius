defmodule Bibliotheca.Repo.Migrations.AddFederalLawArticleIndex do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX federal_articles_article_body_trgm_index ON federal_articles USING gin (article_body gin_trgm_ops);"
  end

  def down do
    execute "DROP INDEX federal_articles_article_body_trgm_index;"
  end
end
