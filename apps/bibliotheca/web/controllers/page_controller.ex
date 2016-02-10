defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.RegistrationController
  alias Bibliotheca.User

  def index(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end
end
