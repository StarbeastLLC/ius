defmodule Bibliotheca.TesisController do
  use Bibliotheca.Web, :controller
  
  alias Bibliotheca.{Repo, Tesis}

  def show(conn, %{"ius" => ius}) do
    tesis = Repo.get!(Tesis, ius)
    render(conn, "show.html", tesis: tesis)
  end
end