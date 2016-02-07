defmodule Bibliotheca.RegistrationController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
  	changeset = Elegua.changeset(%User{}, user_params)
  	|> User.changeset(user_params)

  	Elegua.register(changeset)
  	redirect conn, to: "/"
  end
end