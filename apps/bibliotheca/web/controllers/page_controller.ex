defmodule Bibliotheca.PageController do
  use Bibliotheca.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
