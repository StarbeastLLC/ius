defmodule Bibliotheca.Tesis do
  use Bibliotheca.Web, :model

  @primary_key {:ius, :integer, []}
  @derive {Phoenix.Param, key: :ius}

  schema "tesis" do
    field :rubro, :string
    field :texto, :string
    field :precedentes, :string
    field :locabr, :string
    field :sala, :integer
  end

  alias Bibliotheca.{Tesis, Repo}

  def search_texto(search_term) do
    query = from(tesis in Tesis,
    where: fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)", ^search_term))
    Repo.all(query) 
  end

  def search_rubro(search_term) do
    query = from(tesis in Tesis,
    where: fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)", ^search_term))
    Repo.all(query) 
  end

  def search_precedentes(search_term) do
    query = from(tesis in Tesis,
    where: fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)", ^search_term))
    Repo.all(query) 
  end

end