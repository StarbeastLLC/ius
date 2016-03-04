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
  def search(search_term) do
    query = from(article in FederalArticle,
    where: fragment("to_tsvector('spanish', article_body) @@ plainto_tsquery('spanish', ?)", ^search_term),
    preload: [:federal_law])
    #where: fragment("similarity(?, ?) > ?", article.article_body, ^search_term, ^threshold),
    #order_by: fragment("similarity(?, ?) DESC", article.article_body, ^search_term))
    Repo.all(query) 
  end

  def by_law(law_id) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id,
    order_by: [desc: article.id])
    Repo.all(query)
  end
end
