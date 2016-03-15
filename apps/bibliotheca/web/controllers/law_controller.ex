defmodule Bibliotheca.LawController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.{User, FederalArticle, SearchService, FederalLaw, Tesis}
  alias Lex.LawParser

  plug :scrub_params, "law" when action in [:create, :update]

  def index(conn, _params) do
    laws = Repo.all(FederalLaw)
    render(conn, "index.html", laws: laws)
  end

  def load(conn, _params) do
    {:ok, files} = File.ls("docs/federales")
    # export_file("2_241213.txt")
    # export_file("149.txt")
    # Enum.each(files, &export_file_async(&1))
    Enum.each(files, &export_file(&1))

    laws = Repo.all(FederalLaw)
    render(conn, "index.html", laws: laws)
  end

  defp export_file_async(file) do
    spawn(fn -> export_file(file) end)
  end

  defp export_file(file) do
    IO.puts "Processing file: " <> file
    case LawParser.parse_file("docs/federales/" <> file, false) do
      {:ok, content} ->
        law =
          %FederalLaw{
            file_name: file,
            name: content[:title],
            header: content[:header],
            reform_date: content[:reform_date],
            original_text: content[:original_text],
            articles: content[:body],
            contents: %{}
          }
        Repo.transaction fn ->
          new_law = Repo.insert!(law)

          # Build a article from the law struct
          article_json = content[:body]
          Enum.each(article_json, fn {key, value} ->
          IO.inspect key
          article = Ecto.build_assoc(new_law, :federal_articles, article_number: key, article_body: value)
          Repo.insert!(article) end)
        end

      {:error, error} ->
        IO.puts error
    end
  end

  def new(conn, _params) do
    changeset = FederalLaw.changeset(%FederalLaw{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"law" => law_params}) do
    changeset = FederalLaw.changeset(%FederalLaw{}, law_params)

    case Repo.insert(changeset) do
      {:ok, _law} ->
        conn
        |> put_flash(:info, "FederalLaw created successfully.")
        |> redirect(to: law_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    law = Repo.get!(FederalLaw, id)
    articles = FederalArticle.by_law(id)
    render(conn, "show.html", law: law, articles: articles)
  end

  def edit(conn, %{"id" => id}) do
    law = Repo.get!(FederalLaw, id)
    changeset = FederalLaw.changeset(law)
    render(conn, "edit.html", law: law, changeset: changeset)
  end

  def update(conn, %{"id" => id, "law" => law_params}) do
    law = Repo.get!(FederalLaw, id)
    changeset = FederalLaw.changeset(law, law_params)

    case Repo.update(changeset) do
      {:ok, law} ->
        conn
        |> put_flash(:info, "FederalLaw updated successfully.")
        |> redirect(to: law_path(conn, :show, law))
      {:error, changeset} ->
        render(conn, "edit.html", law: law, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    law = Repo.get!(FederalLaw, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(law)

    conn
    |> put_flash(:info, "Law deleted successfully.")
    |> redirect(to: law_path(conn, :index))
  end

  # SEARCHES
  def search_federal(conn, %{"search" => %{"term" => search_term}}) do
    terms = SearchService.separate_terms(search_term)
    articles = search_term
             |> SearchService.clean_search_term
             |> FederalArticle.search
    
    render conn, Bibliotheca.PageView, "federal.html", articles: articles, terms: terms, laws: [], articles_by_law: []
  end
end
