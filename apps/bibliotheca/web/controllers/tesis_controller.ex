defmodule Bibliotheca.TesisController do
  use Bibliotheca.Web, :controller
  
  alias Bibliotheca.{Repo, Tesis, PageView, SearchService}

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
  def search(conn, %{"search" => search_params}) do
    search_term = search_params["term"]
    named_fields = ["rubro", "texto", "precedentes"]
                 |> Enum.zip([search_params["rubro"], 
                              search_params["texto"], 
                              search_params["precedentes"]])
    types = ["tesis", "juris"]
          |> Enum.zip([search_params["tesis"],
                       search_params["juris"]])
    case search_level = String.to_integer(search_params["search_level"]) do
      # Laxe search
      1 ->
        [laxe_term, _] = search_term
                       |> SearchService.clean_search_term
        tesis_ = Tesis.laxe_search(laxe_term, named_fields, types)
      # Strict search
      2 ->
        [_, strict_term] = search_term
                         |> SearchService.clean_search_term
        tesis_ = Tesis.strict_search(strict_term, named_fields, types)      
    end
    render conn, PageView, "tesis.html", tesis_: tesis_
  end

  def search(conn, _params), do: render conn, PageView, "tesis.html", tesis_: []
end