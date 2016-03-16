defmodule Bibliotheca.Repo.Migrations.IndexArticleTitles do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX name_index ON federal_laws USING gin(to_tsvector('spanish',name));"
  end

  def down do
    execute "DROP INDEX name_index;"
  end
end
