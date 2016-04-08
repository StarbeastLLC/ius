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
    field :tpotesis, :integer
  end

  alias Bibliotheca.{Tesis, Repo}

  def search([rubro_term, texto_term, precedentes_term]) do
    query = from(tesis in Tesis,
    where: fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)", ^rubro_term) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)", ^texto_term)
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)", ^precedentes_term))
    Repo.all(query) 
  end

  # Jurisprudencias have a 6 in the tpotesis column
  def search_tesis([rubro_term, texto_term, precedentes_term]) do
    query = from(tesis in Tesis,
    where: tesis.tpotesis != 6
           and fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)", ^rubro_term) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)", ^texto_term)
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)", ^precedentes_term))
    Repo.all(query) 
  end

  def search_juris([rubro_term, texto_term, precedentes_term]) do
    query = from(tesis in Tesis,
    where: tesis.tpotesis == 6
           and fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)", ^rubro_term) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)", ^texto_term)
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)", ^precedentes_term))
    Repo.all(query) 
  end

end