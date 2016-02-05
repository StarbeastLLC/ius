defmodule Bibliotheca.RegistrationController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end
end