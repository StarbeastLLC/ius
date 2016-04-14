defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.RegistrationController
  alias Bibliotheca.{User, FederalArticle, SearchService, FederalLaw, Tesis, Repo}

  def index(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end

  def search_federal_title(conn, %{"search" => %{"term" => search_term, "law_id" => law_id, "ranking" => ranking}}) do
    terms = SearchService.separate_terms(search_term)
    law = Repo.get(FederalLaw, law_id)
    articles_by_law = search_term
                    |> SearchService.clean_search_term
                    |> FederalArticle.search_by_law(law_id, String.to_integer(ranking))
    render conn, "federal.html", articles: [], terms: terms, laws: [law], articles_by_law: articles_by_law, ranking: ranking
  end

  def search_federal_title(conn, %{"search" => %{"title_term" => search_term}}) do
    terms = SearchService.separate_terms(search_term)
    laws = search_term
         |> SearchService.clean_search_term
         |> FederalLaw.search_title
    render conn, "federal.html", articles: [], terms: terms, laws: laws, articles_by_law: []
  end

  def search_federal(conn, _params) do
    render conn, "federal.html", articles: [], laws: [], articles_by_law: [] 
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
