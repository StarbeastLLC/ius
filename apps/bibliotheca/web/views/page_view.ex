defmodule Bibliotheca.PageView do
  use Bibliotheca.Web, :view

  alias Bibliotheca.SearchService, [as: Search]

  def highlighted_article(article, terms) do
    yellow_start = "<span style='background-color:yellow;'><strong>"
    yellow_end = "</strong></span>"

    article = Enum.reduce(terms, article, fn(term, article) ->
                yellow_term =  yellow_start <> term <> yellow_end
                String.replace(article, term, yellow_term)
              end)

    article
    |> String.replace(">>>", yellow_start)
    |> String.replace("<<<", yellow_end)
  end

  def join_highlighted_article(highlights, articles) do
    Enum.zip(highlights, articles)
    |> Enum.map(fn({highlight, article}) -> [highlight: highlight, article: article] end)
  end

  def law_id(articles) do
    first = Enum.at(articles, 0)
    first.federal_law_id
  end

  def law_name(articles) do
    first = Enum.at(articles, 0)
    first.federal_law.name
  end
end
