defmodule Bibliotheca.PageView do
  use Bibliotheca.Web, :view

  def highlighted_article(article, terms) do
    bold_term = "<span style='background-color:yellow;'><strong>" <> Enum.at(terms, 0) <> "</strong></span>"
    String.replace(article, Enum.at(terms, 0), bold_term)
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
