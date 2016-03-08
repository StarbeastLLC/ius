defmodule Bibliotheca.PageView do
  use Bibliotheca.Web, :view

  def highlighted_article(article, terms) do
    bold_term = "<span style='background-color:yellow;'><strong>" <> Enum.at(terms, 0) <> "</strong></span>"
    String.replace(article, Enum.at(terms, 0), bold_term)
  end
end
