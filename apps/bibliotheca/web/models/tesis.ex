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

  def laxe_search(term, fields, types) do
    query = filter_types(types)
    terms = filter_fields(fields, term)
    _query = from(tesis in query,
    where: fragment("tsv_rubro @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 0))
        or fragment("tsv_texto @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 1))
        or fragment("tsv_precedentes @@ to_tsquery('spanish', ?)", 
                    ^Enum.at(terms, 2))
    )
    Repo.all(_query)
  end

  def strict_search([laxe_term, strict_term], fields, types) do
    query = filter_types(types)
    laxe_terms = filter_fields(fields, laxe_term)
    strict_terms = filter_fields(fields, strict_term)
    _query = from(tesis in query,
    where: fragment("tsv_rubro @@ to_tsquery('spanish', ?) 
                     AND UPPER(UNACCENT(rubro)) LIKE ALL(?)", 
                     ^Enum.at(laxe_terms, 0), ^Enum.at(strict_terms, 0))
        or fragment("tsv_texto @@ to_tsquery('spanish', ?) 
                     AND UPPER(UNACCENT(texto)) LIKE ALL(?)", 
                     ^Enum.at(laxe_terms, 1), ^Enum.at(strict_terms, 1))
        or fragment("tsv_precedentes @@ to_tsquery('spanish', ?) 
                     AND UPPER(UNACCENT(precedentes)) LIKE ALL(?)", 
                     ^Enum.at(laxe_terms, 2), ^Enum.at(strict_terms, 2))
    )
    Repo.all(_query)
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