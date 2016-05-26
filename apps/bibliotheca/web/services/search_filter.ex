defmodule Bibliotheca.SearchFilterService do
  def searchable_laws(laws_ids, selected_laws) do
    selected_laws = parse_checkboxes(selected_laws)
  end

  def parse_checkboxes(["empty", "true" | tail]), do: [true] ++ parse_checkboxes(tail)
  def parse_checkboxes(["empty", "empty" | tail]), do: [false] ++ parse_checkboxes(["empty" | tail])
  def parse_checkboxes(["empty"]), do: [false]
  def parse_checkboxes([]), do: []
end
