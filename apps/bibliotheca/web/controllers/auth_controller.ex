defmodule Bibliotheca.AuthController do
  use Bibliotheca.Web, :controller

  def login(conn, %{"user" => user_params}) do
    case Elegua.authenticate({:email, user_params["email"]}, user_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: "/")
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
end