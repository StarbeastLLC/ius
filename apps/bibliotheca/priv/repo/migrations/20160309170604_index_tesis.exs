defmodule Bibliotheca.Repo.Migrations.IndexTesis do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX rubro_index ON tesis USING gin(to_tsvector('spanish',rubro));"
    execute "CREATE INDEX texto_index ON tesis USING gin(to_tsvector('spanish',texto));"
    execute "CREATE INDEX precendentes_index ON tesis USING gin(to_tsvector('spanish',precedentes));"
    execute "CREATE INDEX locabr_index ON tesis USING gin(to_tsvector('spanish',locabr));"
  end

  def down do
    execute "DROP INDEX rubro_index;"
    execute "DROP INDEX texto_index;"
    execute "DROP INDEX precedentes_index;"
    execute "DROP INDEX locabr_index;"
  end
end
