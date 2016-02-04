defmodule Bibliotheca.Law do
  use Bibliotheca.Web, :model

  schema "laws" do
    field :file_name,     :string
    field :name,          :string
    field :header,        :string
    field :reform_date,   :string
    field :original_text, :string
    field :json_text,     :map

    timestamps
  end

  @required_fields ~w(file_name name header reform_date original_text json_text)
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
