defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view

  alias Bibliotheca.{FederalArticle, Repo, ContentsTable}
  alias Bibliotheca.AsciiTableParserService, as: AsciiTableParser

  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end

  def has_search_terms(article, found_articles) do
    Enum.member?(found_articles, to_string(article.id))
  end

  def clear_header(header) do
    header
    |> String.replace(~r([+|-]), "")
    |> String.split(~r(\n))
    |> Enum.map(&String.strip/1)
  end

  def clear_article(article) do
    article
    |> AsciiTableParser.parse_table
  end
end
