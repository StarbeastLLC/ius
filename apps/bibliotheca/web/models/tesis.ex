defmodule Bibliotheca.Tesis do
  use Bibliotheca.Web, :model
  alias Bibliotheca.{Tesis, Repo}
  alias Ecto.Adapters.SQL

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

  def search([{fts_rubro, like_rubro}, {fts_texto, like_texto}, {fts_precedentes, like_precedentes}]) do
    query = from(tesis in Tesis,
    where: fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)
                     AND rubro LIKE ?", ^fts_rubro, ^Enum.at(like_rubro, 0)) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)
                     AND texto LIKE ?", ^fts_texto, ^Enum.at(like_texto, 0))
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)
                     AND precedentes LIKE ?", ^fts_precedentes, ^Enum.at(like_precedentes, 0)))
    Repo.all(query) 
  end

  def laxe_search(term, fields, types) do
    query = filter_types(types)
    terms = filter_fields(fields, term)
    _query = from(tesis in query,
    where: fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 0))
        or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 1))
        or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 2))
    )
    Repo.all(_query)
  end

  # Jurisprudencias have a 6 in the tpotesis column
  def search_tesis([{fts_rubro, like_rubro}, {fts_texto, like_texto}, {fts_precedentes, like_precedentes}]) do
    query = from(tesis in Tesis,
    where: tesis.tpotesis != 6
           and fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)
                     AND rubro LIKE ?", ^fts_rubro, ^Enum.at(like_rubro, 0)) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)
                     AND texto LIKE ?", ^fts_texto, ^Enum.at(like_texto, 0))
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)
                     AND precedentes LIKE ?", ^fts_precedentes, ^Enum.at(like_precedentes, 0)))
    Repo.all(query) 
  end

  def search_juris([{fts_rubro, like_rubro}, {fts_texto, like_texto}, {fts_precedentes, like_precedentes}]) do
    query = from(tesis in Tesis,
    where: tesis.tpotesis == 6
           and fragment("to_tsvector('spanish', rubro) @@ to_tsquery('spanish', ?)
                     AND rubro LIKE ?", ^fts_rubro, ^Enum.at(like_rubro, 0)) 
           or fragment("to_tsvector('spanish', texto) @@ to_tsquery('spanish', ?)
                     AND texto LIKE ?", ^fts_texto, ^Enum.at(like_texto, 0))
           or fragment("to_tsvector('spanish', precedentes) @@ to_tsquery('spanish', ?)
                     AND precedentes LIKE ?", ^fts_precedentes, ^Enum.at(like_precedentes, 0)))
    Repo.all(query) 
  end

  defp query_tesis, do: from(tesis in Tesis, where: tesis.tpotesis == 6)
  defp query_juris, do: from(tesis in Tesis, where: tesis.tpotesis != 6)
  defp filter_types([tesis, juris]) do
    cond do
      tesis == {"tesis", "false"} -> query_juris
      juris == {"juris", "false"} -> query_tesis
      :else -> Tesis
    end
  end
  
  defp filter_fields(fields, term) do
    fields = Enum.map(fields, fn(x) -> 
              {field, value} = x
              if value do
                term
              else
                ""
              end
    end)
  end

end