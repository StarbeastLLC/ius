defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view
  import Poison
  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end
end
