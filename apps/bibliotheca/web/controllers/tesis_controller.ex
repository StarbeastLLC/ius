defmodule Bibliotheca.TesisController do
  use Bibliotheca.Web, :controller
  
  alias Bibliotheca.{Repo, Tesis, PageView}

  def show(conn, %{"ius" => ius}) do
    case tesis = Repo.get(Tesis, ius) do
      nil -> 
        conn
        |> put_flash(:error, "No hay tesis o jurisprudencias con ese ius")
        |> redirect(to: "/tesis")
      %Bibliotheca.Tesis{} -> render(conn, "show.html", tesis: tesis)
    end 
  end
  def search_ius(conn, %{"search" => ius_params}), do: show(conn, ius_params)
end