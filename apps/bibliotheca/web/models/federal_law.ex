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

  def strict_search([laxe_term, strict_term]) do
    query = from(law in FederalLaw,
    where: fragment("to_tsvector('spanish', name)
                     @@ to_tsquery('spanish', ?)", ^laxe_term),
    preload: [:federal_articles])
    Repo.all(query)
  end

  def multiple_by_id(ids) do
    Enum.map(ids, fn(id)->
      Repo.one(FederalLaw, id)
    end)
  end
end
