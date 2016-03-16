defmodule Bibliotheca.FederalLaw do
  use Bibliotheca.Web, :model

  alias Bibliotheca.{FederalLaw, Repo}

  schema "federal_laws" do
    field :file_name,     :string
    field :name,          :string
    field :header,        :string
    field :reform_date,   :string
    field :original_text, :string
    field :articles,      :map
    field :contents,      :map

    has_many :federal_articles, Bibliotheca.FederalArticle
    timestamps
  end

  @required_fields ~w(file_name name header reform_date original_text articles contents)
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

  def search_title(search_term) do
    query = from(law in FederalLaw,
    where: fragment("to_tsvector('spanish', name) @@ to_tsquery('spanish', ?)", ^search_term),
    preload: [:federal_articles])
    #where: fragment("similarity(?, ?) > ?", article.article_body, ^search_term, ^threshold),
    #order_by: fragment("similarity(?, ?) DESC", article.article_body, ^search_term))
    Repo.all(query) 
  end
end
