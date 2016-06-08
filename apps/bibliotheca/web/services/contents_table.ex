defmodule Bibliotheca.ContentsTable do
  alias Bibliotheca.FederalArticle
  require IEx

  def index(articles, law) do
    contents = real_contents(law)
    sections = Enum.map(contents, fn(x)-> Enum.at(x, 1) end)
    case sections do
      [] -> [["ÍNDICE GENERAL", articles]]
      _ ->
        {articles_by_section, _} = articles_by_section(contents, articles, law)
        toc = Enum.zip(sections, articles_by_section)
        Enum.map(toc, fn(x)->
          Tuple.to_list(x)
        end)
    end
  end

  def separate_section(text) do
    text
    |> replace_capitulo
    |> replace_titulo
  end

  def real_contents(law) do
    if law.contents != %{} do
      law.contents["ct"]
    else
      []
    end
  end

  defp replace_capitulo(text) do
    text
    |> String.replace(" CAPITULO", "<br> CAPITULO")
    |> String.replace(" CAPÍTULO", "<br> CAPÍTULO")
    |> String.replace(" Capítulo", "<br> Capítulo")
  end

  defp replace_titulo(text) do
    text
    |> String.replace(" TITULO", "<br> TITULO")
    |> String.replace(" TÍTULO", "<br> TÍTULO")
    |> String.replace(" Título", "<br> Título")
  end

  defp articles_by_section(contents, articles, law) do
    articles_mark_number = Enum.map(contents, fn(x)-> Enum.at(x, 0) end)
                        |> ignore_title_mark
    first_article = ignore_title(articles)
    Enum.map_reduce(articles_mark_number, first_article.id, fn(x, acc)->
      last_article = FederalArticle.by_number(law.id, x)
                   |> Enum.at(0)

      articles_by_section = FederalArticle.by_range(acc, last_article.id)
      {articles_by_section, last_article.id + 1}
    end)
  end

  defp ignore_title(articles) do
    if Enum.at(articles, 0) != "0" do
      Enum.at(articles, 0)
    else
      Enum.at(articles, 1)
    end
  end

  defp ignore_title_mark(article_marks) do
    if Enum.at(article_marks, 0) != "0" do
      article_marks
    else
      Enum.drop(article_marks, 1)
    end
  end
end
