defmodule Bibliotheca.FacebookController do
  use Bibliotheca.Web, :controller
  import Ecto.Changeset, only: [put_change: 3, cast: 4]
  alias Bibliotheca.User

  @fb_fields ~w(email first_name last_name fb_id fb_token is_verified)
  @google_fields ~w(email first_name last_name google_id is_verified)

  def auth(conn, %{"user" => user_params}) do
    user_params = Map.put(user_params, "is_verified", true)
    user = Repo.get_by(User, email: user_params["email"])
    cond do
      user && user.fb_id == user_params["fb_id"] ->
        login(conn, user)
      user && user.google_id == user_params["google_id"] ->
        login(conn, user)
      user ->
        case bind_account(user, user_params) do
          {:ok, user} ->
            conn
            |> put_session(:user_id, user.id)
            |> put_flash(:info, "You connected #{determine_service(user_params)} to your account!")
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

  defp determine_service(user_params) do
    cond do
      Map.has_key?(user_params, "fb_id") == true -> "Facebook"
      Map.has_key?(user_params, "google_id") == true -> "Google+"
    end
  end
  
  defp bind_account(user, user_params) do
    cond do
      Map.has_key?(user_params, "fb_id") == true ->
        fb_params = %{
          :fb_id => user_params["fb_id"],
          :fb_token => user_params["fb_token"]
        }
        update_user(user, fb_params, @fb_fields)
      Map.has_key?(user_params, "google_id") == true ->
        google_params = %{:google_id => user_params["google_id"]}
        update_user(user, google_params, @google_fields)
    end   
  end

  defp update_user(user, params, fields) do
    changeset = cast(user, params, fields, [])
      case Repo.update(changeset) do
        {:ok, user} -> {:ok, user}
        {:error, _} -> :error
    end
  end

  defp register(user_params) do
    cond do
      Map.has_key?(user_params, "fb_id") == true ->
        changeset = cast(%User{}, user_params, @fb_fields, [])
      Map.has_key?(user_params, "google_id") == true ->
        changeset = cast(%User{}, user_params, @google_fields, [])
    end
    case Repo.insert(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, _} -> :error
    end
  end

end