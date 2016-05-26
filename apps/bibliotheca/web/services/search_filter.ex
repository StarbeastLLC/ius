defmodule Bibliotheca.SearchFilterService do
  require IEx
  def searchable_laws(laws_ids, selected_laws) do
    selected_laws = parse_checkboxes(selected_laws)
                  |> Enum.zip(laws_ids)
                  |> searchable_laws
                  |> Enum.filter(fn(id)-> id end)
    IEx.pry
  end

  defp searchable_laws(marked_laws) do
    Enum.map(marked_laws, fn(x)->
      case x do
        {true, law_id} -> String.to_integer(law_id)
        {false, law_id} -> nil
      end
    end)
  end

  defp parse_checkboxes(["empty", "true" | tail]), do: [true] ++ parse_checkboxes(tail)
  defp parse_checkboxes(["empty", "empty" | tail]), do: [false] ++ parse_checkboxes(["empty" | tail])
  defp parse_checkboxes(["empty"]), do: [false]
  defp parse_checkboxes([]), do: []
end
