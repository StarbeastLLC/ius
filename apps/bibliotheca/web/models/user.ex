defmodule Bibliotheca.User do
  use Bibliotheca.Web, :model

  schema "users" do
    field :password, :string
    field :new_password, :string

    field :username, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :state, :string

    field :fb_id, :string
    field :fb_token, :string

    field :verification_token, :string
    field :is_verified, :boolean, default: false

    field :accepts_terms, :boolean, default: false
    field :accepts_cookies, :boolean, default: false

    field :rfc, :string
    field :legal_name, :string
    field :legal_address, :string
    field :legal_email, :string

    timestamps
  end

  @required_fields ~w(password username email is_verified first_name last_name accepts_terms accepts_cookies state)
  @optional_fields ~w(verification_token new_password fb_id fb_token legal_name legal_address legal_email rfc)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:email, ~r/@/)
    |> validate_format(:legal_email, ~r/@/)
    |> unique_constraint(:email, on: Bibliotheca.Repo, downcase: true)
    |> unique_constraint(:username, on: Bibliotheca.Repo, downcase: true)
  end
end
