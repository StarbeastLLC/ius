defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.RegistrationController
  alias Bibliotheca.{User, FederalArticle, SearchService}

  def index(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end

  def search_federal(conn, %{"search" => %{"term" => search_term}}) do
    terms = SearchService.separate_terms(search_term)
    articles = search_term
             |> SearchService.clean_search_term
             |> FederalArticle.search
    
    render conn, "federal.html", articles: articles, terms: terms
  end

  def search_federal(conn, _params) do
    render conn, "federal.html", articles: []
  end

  def search_2(conn, _params) do
    render conn, "search-2.html"
  end

  def search_3(conn, _params) do
    render conn, "search-3.html"
  end

  def search_4(conn, _params) do
    render conn, "search-4.html"
  end

  def search_5(conn, _params) do
    render conn, "search-5.html"
  end
end
