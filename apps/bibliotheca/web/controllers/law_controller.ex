defmodule Bibliotheca.LawController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.{User, FederalArticle, SearchService, FederalLaw, Tesis, PageView}
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
            articles: %{}, #content[:body],
            contents: content[:content_table]
          }
        # IO.inspect content[:content_table]

        Repo.transaction fn ->
          new_law = Repo.insert!(law)
  {"34",
   "TITULO CUARTO\n\n                               Del Registro Civil\n\n                                   CAPITULO I\n\n                            Disposiciones Generales"}
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
  def search(conn, %{"search" => %{"term" => search_term, "search_level" => search_level}}) do
    terms_ = SearchService.separate_terms(search_term)
    case String.to_integer(search_level) do
      # Laxe search
      1 ->
        [laxe_term, _] = search_term
                       |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.laxe_search(laxe_term)
                            |> Enum.unzip
        {highlights, articles} = highlights_articles
      # Strict search
      2 ->
        terms = search_term
              |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.strict_search(terms)
                            |> Enum.unzip
        {highlights, articles} = highlights_articles
    end
    render conn, PageView, "federal.html", articles: articles, terms: terms_, laws: [], articles_by_law: [], highlights: highlights
  end

  def search(conn, _params) do
    render conn, PageView, "federal.html", articles: [], laws: [], articles_by_law: [], highlights: []
  end

  def search_title(conn, %{"search" => %{"term" => search_term, "law_id" => law_id, "search_level" => search_level}}) do
    terms_ = SearchService.separate_terms(search_term)
    law = Repo.get(FederalLaw, law_id)
    case String.to_integer(search_level) do
      # Laxe search
      1 ->
        [laxe_term, _] = search_term
                       |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.laxe_search(law_id, laxe_term)
                            |> Enum.unzip
        {highlights, articles_by_law} = highlights_articles
      # Strict search
      2 ->
        terms = search_term
              |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.strict_search(law_id, terms)
                            |> Enum.unzip
        {highlights, articles_by_law} = highlights_articles
    end
    render conn, PageView, "federal.html", articles: [], terms: terms_, laws: [law], articles_by_law: articles_by_law, highlights: highlights
  end

  def search_title(conn, %{"search" => %{"title_term" => search_term}}) do
    terms = SearchService.separate_terms(search_term)
    # Strict search by default
    laws = search_term
         |> SearchService.clean_search_term
         |> FederalLaw.strict_search
    render conn, PageView, "federal.html", articles: [], terms: terms, laws: laws, articles_by_law: [], highlights: []
  end
end
