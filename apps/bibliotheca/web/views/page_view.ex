defmodule Bibliotheca.PageView do
  use Bibliotheca.Web, :view

  def highlighted_article(article, terms) do
    yellow_start = "<span style='background-color:yellow;'><strong>"
    yellow_end = "</strong></span>"
    yellow_term =  yellow_start <> Enum.at(terms, 0) <> yellow_end
    article = String.replace(article, Enum.at(terms, 0), yellow_term)
    article = String.replace(article, ">>>", yellow_start)
    article = String.replace(article, "<<<", yellow_end)
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
