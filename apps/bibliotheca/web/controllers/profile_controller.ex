defmodule Bibliotheca.ProfileController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User
  import Ecto.Changeset, only: [put_change: 3, change: 2]

  @from "postmaster@sandbox9ddf700296ad4bf0a817cedfe2a09d99.mailgun.org"
  @password_greeting "You changed your Lexi password!"
  @deletion_message "It's sad to let you go! -Lexi"

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
    password_changeset = User.changeset(%User{})
    changeset = User.update_changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Your profile has been updated")
        |> redirect(to: "/profile")
      {:error, changeset} ->
        if changeset.constraints != [] do
          conn
          |> put_flash(:error, "Email is already taken!")
          |> render("profile.html", user: user, changeset: changeset, password_changeset: password_changeset)
        else
          conn
          |> put_flash(:error, "Please try again!")
          |> render("profile.html", user: user, changeset: changeset, password_changeset: password_changeset)
        end
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

  def close_account(conn, _params) do
    user_id = get_session(conn, :user_id)
    user = Repo.get(User, user_id)
    token = Ecto.UUID.generate
    changeset = user
                  |> change(%{})
                  |> put_change(:verification_token, token)
    case Repo.update(changeset) do
      {:ok, user} ->
        verification_token = user.verification_token
        user_email = user.email
        content = "Confirm your account deletion by clicking on this link: http://lexi.mx/account-deletion/#{verification_token}"
        Elegua.send_verification_email(user_email, @from, @deletion_message, {:text, content})

        conn
        |> put_flash(:info, "We emailed you a link to verify this action")
        |> redirect(to: "/")
      {:error, _} ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/")
    end
  end

  def delete_account(conn, %{"token" => token}) do
    user = Repo.get_by(User, verification_token: token)
    case Repo.delete(user) do
      {:ok, _} -> 
        conn
        |> delete_session(:user_id)
        |> delete_session(:session_token)
        |> put_flash(:info, "Your account was deleted!")
        |> redirect(to: "/")
      {:error, _} ->
        conn
        |> put_flash(:info, "Please try again")
        |> redirect(to: "/")
    end
  end
end