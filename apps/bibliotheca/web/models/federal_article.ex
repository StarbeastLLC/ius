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
  
  # Postgres' 'set_limit' sets a threshold for the search term
  # If 'threshold = 1' and we search "laborales", it will look for the exact word
  # In doubt, refer to the docs: http://www.postgresql.org/docs/9.1/static/pgtrgm.html
  def search([fts_term, like_term], ranking) do
    query = from(article in FederalArticle,
    where: fragment("to_tsvector('spanish', article_body) @@ plainto_tsquery('spanish', ?)
                     AND article_body LIKE ALL(?)",
                                # Right now we search only for the first phrase
                     ^fts_term, ^like_term) 
       and fragment("(ts_rank_cd(to_tsvector('spanish', article_body), to_tsquery('spanish', ?)) * 100) > ?",
                     ^fts_term, ^ranking),
    limit: 1000,
    #update: [set: [article_body: fragment("ts_headline('spanish', article.article_body, ?))", ^search_term)]],
    #' <- Esto va en el fragment
    #select: {article, (fragment("ts_headline('spanish', article_body, plainto_tsquery(?))", ^search_term))},
    #order_by: [article.article_number],
    order_by: [desc: fragment("ts_rank_cd(to_tsvector('spanish', article_body), to_tsquery('spanish', ?))", ^fts_term)],
    preload: [:federal_law])
    #where: fragment("similarity(?, ?) > ?", article.article_body, ^search_term, ^threshold),
    #order_by: fragment("similarity(?, ?) DESC", article.article_body, ^search_term))
    Repo.all(query) 
  end

  def search_by_law([fts_term, like_term], law_id, ranking) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id 
       and fragment("to_tsvector('spanish', article_body) @@ to_tsquery('spanish', ?)
                     AND article_body LIKE ?", ^fts_term, ^Enum.at(like_term, 0))
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
end
