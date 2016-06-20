defmodule Bibliotheca.LawController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.{User, FederalArticle, SearchService,
                     FederalLaw, Tesis, PageView, ContentsTable}
  alias Bibliotheca.SearchFilterService, as: SearchFilter
  alias Lex.LawParser

  plug :scrub_params, "law" when action in [:create, :update]

  def index(conn, _params) do
    laws = Repo.all(FederalLaw)
    render(conn, "index.html", laws: laws)
  end

  def load do
    {:ok, files} = File.ls("docs/federales")
    # export_file("2_241213.txt")
    # export_file("149.txt")
    # Enum.each(files, &export_file_async(&1))
    Enum.each(files, &export_file(&1))
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

  def toc(conn, %{"id" => id}) do
    law = Repo.get!(FederalLaw, id)
    articles = FederalArticle.by_law(id)
    contents_table = ContentsTable.index(articles, law)
    render(conn, "toc.html", law: law, articles: articles,
                              contents_table: contents_table, found_articles: [])
  end

  def toc_from_search(conn, %{"search" => %{"law_id" => id, "found_articles" => found_articles}}) do
    law = Repo.get!(FederalLaw, id)
    articles = FederalArticle.by_law(id)
    contents_table = ContentsTable.index(articles, law)
    render(conn, "toc.html", law: law, articles: articles,
                              contents_table: contents_table,
                              found_articles: found_articles)
  end

  def show(conn, %{"id" => id}) do
    law = Repo.get!(FederalLaw, id)
    articles = FederalArticle.by_law(id)
    contents_table = ContentsTable.index(articles, law)
    render(conn, "show.html", law: law, articles: articles,
                              contents_table: contents_table)
  end

  def show_article(conn, %{"id" => id}) do
    article = Repo.get!(FederalArticle, id)
    law = Repo.get!(FederalLaw, article.federal_law_id)
    articles_by_law = FederalArticle.by_law(law.id)
                    |> Enum.map(fn(article)-> article.id end)
    render(conn, "show_article.html", law: law, article: article,
                                      articles_by_law: articles_by_law)
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
        useful_laws = SearchFilter.laws_from_articles(articles) |> FederalLaw.multiple_by_id

      # Strict search
      2 ->
        terms = search_term
              |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.strict_search(terms)
                            |> Enum.unzip
        {highlights, articles} = highlights_articles
        useful_laws = SearchFilter.laws_from_articles(articles) |> FederalLaw.multiple_by_id
    end
    render conn, PageView, "federal.html", articles: articles, terms: terms_, laws: [],
                                           articles_by_law: [], highlights: highlights,
                                           useful_laws: useful_laws
  end

  def search(conn, _params) do
    render conn, PageView, "federal.html", articles: [], laws: [], articles_by_law: [],
                                           highlights: [], useful_laws: []
  end

  def search_title(conn, %{"search" => %{"term" => search_term, "laws_ids" => laws_ids,
                                         "search_level" => search_level, "selected_laws" => selected_laws}}) do
    terms_ = SearchService.separate_terms(search_term)
    searchable_laws = SearchFilter.searchable_laws(laws_ids, selected_laws)
    laws = FederalLaw.multiple_by_id(searchable_laws)
    case String.to_integer(search_level) do
      # Laxe search
      1 ->
        [laxe_term, _] = search_term
                       |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.multiple_laxe_search(searchable_laws, laxe_term)
                            |> Enum.unzip
        {highlights, articles_by_law} = highlights_articles
        useful_laws = SearchFilter.laws_from_articles(articles_by_law) |> FederalLaw.multiple_by_id

      # Strict search
      2 ->
        terms = search_term
              |> SearchService.clean_search_term
        # This returns a list of tuples containing {"highlited article", %Bibliotheca.FederalArticle}
        highlights_articles = FederalArticle.multiple_strict_search(searchable_laws, terms)
                            |> Enum.unzip
        {highlights, articles_by_law} = highlights_articles
        useful_laws = SearchFilter.laws_from_articles(articles_by_law) |> FederalLaw.multiple_by_id
    end
    render conn, PageView, "federal.html", articles: [], terms: terms_, laws: laws,
                                           articles_by_law: articles_by_law, highlights: highlights,
                                           useful_laws: useful_laws
  end

  def search_title(conn, %{"search" => %{"title_term" => search_term}}) do
    terms = SearchService.separate_terms(search_term)
    # Strict search by default
    laws = search_term
         |> SearchService.clean_search_term
         |> FederalLaw.strict_search
    render conn, PageView, "federal.html", articles: [], terms: terms, laws: laws,
                                           articles_by_law: [], highlights: [],
                                           useful_laws: []
  end

  def show_found_article(conn, %{"search" => %{"article_ids" => article_ids}}) do
    first_article = Repo.get!(FederalArticle, Enum.at(article_ids, 0))
    law = Repo.get!(FederalLaw, first_article.federal_law_id)

    # Here we save in the user session an array with the ids of the found articles
    # and the position of the article currently in view
    conn
    |> put_session(:found_articles, article_ids)
    |> put_session(:found_articles_position, 0)
    |> render("show_found_article.html", article: first_article, law: law,
                                         article_ids: article_ids, position: 0)
  end

  def show_found_article(conn, %{"search" => %{"position" => operation}}) do
    article_ids = get_session(conn, :found_articles)
    # 'operation' can be "minus" and "plus", and it alters the value of
    # ':found_articles_position' in the user session
    case operation do
      "minus" ->
        conn = found_articles_position_changer(conn, :minus)
        position = get_session(conn, :found_articles_position)
        article_id = Enum.at(article_ids, position)
        article = Repo.get!(FederalArticle, article_id)
        law = Repo.get!(FederalLaw, article.federal_law_id)
        render(conn, "show_found_article.html", article: article, law: law,
                                                article_ids: article_ids,
                                                position: position)
      "plus" ->
        conn = found_articles_position_changer(conn, :plus)
        position = get_session(conn, :found_articles_position)
        article_id = Enum.at(article_ids, position)
        article = Repo.get!(FederalArticle, article_id)
        law = Repo.get!(FederalLaw, article.federal_law_id)
        render(conn, "show_found_article.html", article: article, law: law,
                                                article_ids: article_ids,
                                                position: position)
    end
  end

  defp found_articles_position_changer(conn, :minus) do
    current_position = get_session(conn, :found_articles_position)
    conn
    |> put_session(:found_articles_position, current_position - 1)
  end

  defp found_articles_position_changer(conn, :plus) do
    current_position = get_session(conn, :found_articles_position)
    conn
    |> put_session(:found_articles_position, current_position + 1)
  end
end
