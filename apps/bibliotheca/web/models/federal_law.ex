defmodule Bibliotheca.FederalLaw do
  use Bibliotheca.Web, :model

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
end
