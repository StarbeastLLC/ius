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
  
  def update_profile(conn, %{"user" => user_params}) do
    id = get_session(conn, :user_id)
    user = Repo.get_by(User, id: id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Your profile has been updated")
        |> redirect(to: "/profile")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Please try again!")
        |> render("profile.html", user: user, changeset: changeset)
    end
  end
end