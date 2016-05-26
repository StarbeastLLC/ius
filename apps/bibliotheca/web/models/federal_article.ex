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

  def by_range(initial_id, last_id) do
    query = from(article in FederalArticle,
    where: article.id >= ^initial_id
       and article.id <= ^last_id,
    order_by: [asc: article.id]
    )
    Repo.all(query)
  end

  # Exception for the Código Nacional de Procedimientos Penales
  def by_number(186, number) do
    number = number <> "%"
    query = from(article in FederalArticle,
    where: article.federal_law_id == 186
       and fragment("article_number LIKE ?", ^number)
    )
    Repo.all(query)
  end

  def by_number(law_id, number) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id
       and article.article_number == ^number
    )
    Repo.all(query)
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

  def multiple_laxe_search(laws_ids, term) do
    base = laxe_query(term)
    query = from(article in base,
    where: fragment("federal_law_id = ANY(?)", ^laws_ids))
    Repo.all(query)
  end

  def strict_search(law_id, term) do
    base = strict_query(term)
    query = from(article in base,
    where: article.federal_law_id == ^law_id
    )
    Repo.all(query)
  end

  def multiple_strict_search(laws_ids, term) do
    base = strict_query(term)
    query = from(article in base,
    where: fragment("federal_law_id = ANY(?)", ^laws_ids))
    Repo.all(query)
  end

  def by_law(law_id) do
    query = from(article in FederalArticle,
    where: article.federal_law_id == ^law_id,
    limit: 1000,
    order_by: [asc: article.id])
    Repo.all(query)
  end

  defp laxe_query(term) do
    q = from(article in FederalArticle,
    where: fragment("tsv @@ to_tsquery('spanish', ?)", ^term),
    order_by: [desc: fragment("ts_rank_cd(tsv, to_tsquery('spanish', ?))", ^term)],
    preload: [:federal_law]
    )

    from(article in q,
    select: {fragment("ts_headline(article_body, to_tsquery('spanish', ?), 'HighlightAll=TRUE,
              StartSel=>>>, StopSel=<<<')", ^term), article})
  end

  defp strict_query([laxe_term, strict_term]) do
    q = from(article in FederalArticle,
    where: fragment("tsv @@ to_tsquery('spanish', ?)
                     AND UPPER(UNACCENT(article_body)) LIKE ALL(?)", ^laxe_term, ^strict_term),
    order_by: [desc: fragment("ts_rank_cd(tsv, to_tsquery('spanish', ?))", ^laxe_term)],
    preload: [:federal_law]
    )

   from(article in q,
   select: {fragment("ts_headline(article_body, to_tsquery('spanish', ?), 'HighlightAll=TRUE,
              StartSel=>>>, StopSel=<<<')", ^laxe_term), article})
  end
end
