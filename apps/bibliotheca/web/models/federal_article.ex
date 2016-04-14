defmodule Bibliotheca.FederalArticle do
  use Bibliotheca.Web, :model
  alias Bibliotheca.{FederalArticle, Repo}

  schema "federal_articles" do
    field :article_number,  :string
    field :article_body,    :string
    belongs_to :federal_law, Bibliotheca.FederalLaw

    timestamps
  end

  @required_fields ~w(article_body)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def laxe_search(term) do
    term
    |> laxe_query
    |> Repo.all
  end

  def strict_search(terms) do
    terms
    |> strict_query
    |> Repo.all
  end

  def laxe_search(law_id, term) do
    base = laxe_query(term)
    query = from(article in base,
    where: article.federal_law_id == ^law_id
    )
    Repo.all(query)
  end

  def strict_search(law_id, term) do
    base = strict_query(term)
    query = from(article in base,
    where: article.federal_law_id == ^law_id
    )
    Repo.all(query)
  end

  def search_by_law([fts_term, like_term], law_id, ranking) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id 
       and fragment("to_tsvector('spanish', article_body) @@ to_tsquery('spanish', ?)
                     AND article_body LIKE ALL(?)", ^fts_term, ^like_term)
       and fragment("(ts_rank_cd(to_tsvector('spanish', article_body), to_tsquery('spanish', ?)) * 100) > ?",
                     ^fts_term, ^ranking),
    #order_by: [article.article_number],
    limit: 1000,
    order_by: [desc: fragment("ts_rank_cd(to_tsvector('spanish', article_body), to_tsquery('spanish', ?))", ^fts_term)],
    preload: [:federal_law])
    Repo.all(query)
  end

  def by_law(law_id) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id,
    limit: 1000,
    order_by: [desc: article.id])
    Repo.all(query)
  end

  defp laxe_query(term) do
    from(article in FederalArticle,
    where: fragment("to_tsvector('spanish', article_body) 
                     @@ to_tsquery('spanish', ?)", ^term),
    order_by: [desc: fragment("ts_rank_cd(to_tsvector('spanish', article_body), 
                               to_tsquery('spanish', ?))", ^term)],
    preload: [:federal_law]
    )
  end

  defp strict_query([laxe_term, strict_term]) do
    from(article in FederalArticle,
    where: fragment("to_tsvector('spanish', article_body) 
                     @@ to_tsquery('spanish', ?)
                     AND article_body LIKE ALL(?)", ^laxe_term, ^strict_term),
    order_by: [desc: fragment("ts_rank_cd(to_tsvector('spanish', article_body), 
                               to_tsquery('spanish', ?))", ^laxe_term)],
    preload: [:federal_law]
    )
  end
end
