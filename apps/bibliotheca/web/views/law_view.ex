defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view

  alias Bibliotheca.{FederalArticle, Repo}
  require IEx

  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end

  def real_contents(law) do
    if law.contents != %{} do
      law.contents["ct"]
    else
      []
    end
  end

  def style_sections(contents) do
    contents
    |> Enum.map(&separate_sections/1)
    |> Enum.map(&bold_numbers/1)
  end

  def index(contents, articles, law) do
    articles_mark_number = Enum.map(contents, fn(x)-> Enum.at(x, 0) end)
    first_article = Enum.at(articles, 0)
    Enum.map_reduce(articles_mark_number, first_article.id, fn(x, acc)-> 
      last_article = FederalArticle.by_number(law.id, x)
      articles_by_section = FederalArticle.by_range(acc, last_article.id)
      {articles_by_section, last_article.id + 1}
    end)
  end

  defp separate_sections(section) do
    terms = [
            "TITULO",
            "LIBRO",
            "CAPITULO"
            ]
    Enum.reduce(terms, section, fn(term, section) ->
      styled_term = "<br><b>#{term}</b>"
      String.replace(section, term, styled_term)
    end)
  end

  defp bold_numbers(section) do
    terms = [
            "PRIMERO", "SEGUNDO", "TERCERO", "CUARTO", "QUINTO",
            "SEXTO", "SEPTIMO", "OCTAVO", "NOVENO", "DECIMO",
            "I", "II", "III", "IV", "V",
            "VI", "VII", "VIII", "IX", "X",
            "XI", "XII", "XIII", "XIV", "XV",
            "XVI", "XVII", "XVIII", "XIX", "XX"
            ]
    Enum.reduce(terms, section, fn(term, section) ->
      styled_term = "<b>#{term}</b>"
      String.replace(section, term, styled_term)
    end)
  end
end
