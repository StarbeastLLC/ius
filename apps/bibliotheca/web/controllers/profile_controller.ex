defmodule Bibliotheca.ProfileController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User

  @from "postmaster@sandbox9ddf700296ad4bf0a817cedfe2a09d99.mailgun.org"
  @password_greeting "You changed your Lexi password!"

  def profile(conn, _params) do
    id = get_session(conn, :user_id)
    unless id do
      conn
      |> put_flash(:error, "You need to login to continue")
      |> redirect(to: "/")
    end
    user = Repo.get_by(User, id: id)
    changeset = User.changeset(user)
    password_changeset = User.changeset(%User{})
    render(conn, "profile.html", user: user, changeset: changeset, password_changeset: password_changeset)
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

  def new_password(conn, %{"user" => user_params}) do
    id = get_session(conn, :user_id)
    user = Repo.get_by(User, id: id)
    case Elegua.new_password(user.email, user_params["password"]) do
      {:ok, user} ->
        verification_token = user.verification_token
        user_email = user.email
        content = "Confirm your password change by clicking this link: http://lexi.mx/change-password/#{verification_token}"
        Elegua.send_verification_email(user_email, @from, @password_greeting, {:text, content})

        conn
        |> put_flash(:info, "Check your mail to confirm your password change!")
        |> redirect(to: "/")
      {:error, :no_user} ->
        conn
        |> put_flash(:error, "You don't have an account, create one!")
        |> redirect(to: "/register")
      :else ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/")
    end
  end

  def change_password(conn, %{"token" => verification_token}) do
    case Elegua.change_password(verification_token) do
      {:error, :no_user} ->
        conn
        |> put_flash(:error, "Invalid token, please try again!")
        |> redirect(to: "/account-recovery")
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "You changed your password!")
        |> redirect(to: "/profile")
      :else ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/")
    end
  end
end