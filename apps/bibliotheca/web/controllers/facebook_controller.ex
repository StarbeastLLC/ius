defmodule Bibliotheca.FacebookController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User

  def auth(conn, ) do
      
  end

  defp check_status(user_params) do
    user = Repo.get_by(User, user_params["email"])
    cond do
      user && user.fb_id == user_params["fb_id"] ->
        login(conn, user)
      user ->
        :bind
      :else ->
        :register
    end
  end

  defp login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "Welcome back!")
    |> redirect(to: "/")
  end
  
  defp bind_account(conn, user, user_params) do
    fb_params = %{
      :fb_id => user_params["fb_id"],
      :fb_token => user_params["fb_token"]
    }
    changeset = change(user, fb_params)
    case @app_repo.update(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> :error
    end
  end

end