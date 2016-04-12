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

end