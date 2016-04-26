defmodule Bibliotheca.SocialConnectController do
  use Bibliotheca.Web, :controller
  import Ecto.Changeset, only: [put_change: 3, cast: 4]
  alias Bibliotheca.User
  alias Bibliotheca.{AuthController, UserFromAuth}
  alias Ueberauth.Strategy.Helpers

  plug Ueberauth

  @fb_fields ~w(email first_name last_name fb_id is_verified)

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        user_params = Map.put(user, :is_verified, true)
        user = Repo.get_by(User, email: user_params[:email])
        
        cond do
          user && user.fb_id == user_params[:fb_id] ->
            AuthController.check_session_and_login(conn, user)
          user ->
            bind_account(conn, user, user_params)
          user == nil ->
            register(conn, user_params)
        end
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end

  defp bind_account(conn, user, user_params) do
    fb_params = %{
      :fb_id => user_params[:fb_id]
    }
    case update_user(user, fb_params, @fb_fields) do
      {:ok, user} ->
        message = "You connected Facebook to your account!"
        AuthController.check_session_and_login(conn, user, message)
      :else -> 
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/")
    end
  end

  defp update_user(user, params, fields) do
    changeset = cast(user, params, fields, [])
    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, _} -> :error
    end
  end

  defp register(conn, user_params) do
    changeset = cast(%User{}, user_params, @fb_fields, [])
    case Repo.insert(changeset) do
      {:ok, user} ->
        message = "Welcome to Lexi!"
        AuthController.check_session_and_login(conn, user, message)
      {:error, _} ->
        conn
        |> put_flash(:error, "Please try again")
        |> redirect(to: "/") 
    end
  end

end