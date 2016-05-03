defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view

  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end

  def real_contents(%{}), do: []
  def real_contents(contents), do: contents
end
