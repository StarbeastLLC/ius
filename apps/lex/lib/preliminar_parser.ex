defmodule Lex.PreliminarParser do
@docmodule "PRELIMINAR = ARTICULO+"

@preliminar_article_expression ~r{Artículo \d..-}

  def parse_preliminar(preliminar) do
    preliminar_map =
      preliminar
    |> String.split(@preliminar_article_expression)
    |> tl
    |> Stream.with_index
    |> Enum.map(fn({k, v}) -> {"Artículo #{v + 1}", k} end)

    Enum.into(preliminar_map, %{})
  end
end
