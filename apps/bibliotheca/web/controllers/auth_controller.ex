defmodule Bibliotheca.AuthController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User
  alias Bibliotheca.Repo
  alias Bibliotheca.SessionService

  @from "postmaster@sandbox9ddf700296ad4bf0a817cedfe2a09d99.mailgun.org"
  @recovery_greeting "Recover your Lexi account!"

  def forgot_password(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "recover-account.html", changeset: changeset
  end

  def login(conn, %{"user" => user_params}) do
    case Elegua.authenticate({:email, user_params["email"]}, user_params["password"]) do
      {:ok, user} ->
        check_session_and_login(conn, user)
      {:error, :no_user} ->
        conn
        |> put_flash(:error, "Please create an account")
        |> redirect(to: "/register")
      {:error, :invalid_password} ->
        conn
        |> put_flash(:error, "Invalid password")
        |> redirect(to: "/") 
      :else ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/") 
    end
  end

  def logout(conn, _) do
    user_id = get_session(conn, :user_id)
    conn
    |> Elegua.logout
    |> SessionService.delete_session_token(user_id)
    |> put_flash(:info, "Come back soon!")
    |> redirect(to: "/")
  end

  def new_password(conn, %{"user" => user_params}) do
    case Elegua.new_password(user_params["email"], user_params["password"]) do
      {:ok, user} ->
        verification_token = user.verification_token
        user_email = user.email
        content = "Your recovery link: http://lexi.mx/account-recovery/#{verification_token}"
        Elegua.send_verification_email(user_email, @from, @recovery_greeting, {:text, content})

        conn
        |> put_flash(:info, "Check your mail to recover your account!")
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
        message = "You recovered your account, #{user.first_name}!"
        check_session_and_login(conn, user, message)
      :else ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/")
    end
  end

  def check_session_and_login(conn, user, flash_message \\ "Welcome back!") do
    case SessionService.check_session_token(conn, user.id) do
      {:ok, conn} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, flash_message)
        |> redirect(to: "/")
      {:error, :sessions_full} ->
        conn
        |> put_flash(:error, "Log out from another active session to open one in this device")
        |> redirect(to: "/") 
      :else ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/") 
    end
  end
end