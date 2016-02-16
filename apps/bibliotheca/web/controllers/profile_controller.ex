defmodule Bibliotheca.ProfileController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User

  def profile(conn, _params) do
    id = get_session(conn, :user_id)
    unless id do
      conn
      |> put_flash(:error, "You need to login to continue")
      |> redirect(to: "/")
    end
    user = Repo.get_by(User, id: id)
    changeset = User.changeset(user)
    render(conn, "profile.html", user: user, changeset: changeset)
  end

end