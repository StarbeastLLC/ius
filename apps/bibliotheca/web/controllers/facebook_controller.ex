defmodule Bibliotheca.FacebookController do
  use Bibliotheca.Web, :controller
  import Ecto.Changeset, only: [put_change: 3, change: 2]
  alias Bibliotheca.User

  def auth(conn, user_params) do
    user = Repo.get_by(User, user_params["email"])
    cond do
      user && user.fb_id == user_params["fb_id"] ->
        login(conn, user)
      user ->
        case bind_account(user, user_params) do
          {:ok, user} ->
            conn
            |> put_session(:user_id, user.id)
            |> put_flash(:info, "You connected Facebook to your account!")
            |> redirect(to: "/")
          :else -> 
            conn
            |> put_flash(:error, "Please try again")
            |> redirect(to: "/")
        end
      user == nil ->
        case register(user_params) do
          {:ok, user} ->
            conn
            |> put_session(:user_id, user.id)
            |> put_flash(:info, "Welcome to Lexi!")
            |> redirect(to: "/") 
          :else -> 
            conn
            |> put_flash(:error, "Please try again")
            |> redirect(to: "/")        
        end
    end
  end

  defp login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: "/")
  end
  
  defp bind_account(user, user_params) do
    fb_params = %{
      :fb_id => user_params["fb_id"],
      :fb_token => user_params["fb_token"]
    }
    changeset = change(user, fb_params)
    case Repo.update(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> :error
    end
  end

  defp register(user_params) do
    changeset = change(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> :error
    end
  end

end