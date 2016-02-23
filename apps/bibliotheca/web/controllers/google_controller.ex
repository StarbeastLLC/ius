defmodule Bibliotheca.GoogleController do
  use Bibliotheca.Web, :controller
  import Ecto.Changeset, only: [put_change: 3, cast: 4]
  alias Bibliotheca.User

end