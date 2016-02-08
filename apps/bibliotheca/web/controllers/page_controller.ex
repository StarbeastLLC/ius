defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.RegistrationController

  def index(conn, _params) do
    RegistrationController.new(conn, _params)
  end

  def admin?(conn, _params) do
    conn
    |> put_flash(:info, "You shouldn't be here!")
    |> render("key.html")
  end
end
