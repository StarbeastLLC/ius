defmodule Bibliotheca.ContentsTable do
  alias Bibliotheca.FederalArticle

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

  def real_contents(law) do
    if law.contents != %{} do
      law.contents["ct"]
    else
      []
    end
  end

  defp articles_by_section(contents, articles, law) do
    articles_mark_number = Enum.map(contents, fn(x)-> Enum.at(x, 0) end)
    first_article = Enum.at(articles, 0)
    Enum.map_reduce(articles_mark_number, first_article.id, fn(x, acc)-> 
      last_article = FederalArticle.by_number(law.id, x)
                   |> Enum.at(0)
      articles_by_section = FederalArticle.by_range(acc, last_article.id)
      {articles_by_section, last_article.id + 1}
    end)
  end
end