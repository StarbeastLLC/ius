defmodule Lex.TransitoriesParser do
  @docmodule "TRANSITORIOS = TRANSITORIO+ DECRETO+ ARTICULO*"

  @transitories_expression ~r(\s\s\sTRANSITORIO\n|\s\s\sTRANSITORIOS\n)

  def parse_transitories(transitories) do
    transitories_map =
      transitories
    |> String.split(@transitories_expression)
    |> Stream.with_index
    |> Enum.map(fn({k, v}) -> {"Transitorio #{v + 1}", k} end)

    Enum.into(transitories_map, %{})
  end

end
