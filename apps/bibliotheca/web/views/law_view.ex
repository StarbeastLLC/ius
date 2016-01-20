defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view

  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end
end
