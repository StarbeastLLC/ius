defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.RegistrationController

  def index(conn, _params) do
    RegistrationController.new(conn, _params)
  end
end
