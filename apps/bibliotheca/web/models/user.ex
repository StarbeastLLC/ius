defmodule Bibliotheca.User do
  use Bibliotheca.Web, :model

  schema "users" do
    field :password, :string
    field :username, :string
    field :email, :string
    field :verification_token, :string
    field :is_verified, :boolean, default: false
    field :first_name, :string
    field :last_name, :string

    timestamps
  end

  @required_fields ~w(password username email is_verified first_name last_name)
  @optional_fields ~w(verification_token)

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
