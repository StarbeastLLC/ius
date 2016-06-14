defmodule Bibliotheca.FoundArticlesShowService do
  defp separate_id(articles), do: Enum.map(articles, fn(article)-> article.id end)
end
