defmodule Bibliotheca.SessionService do
  import Ecto.Query
  import Ecto.Changeset, only: [put_change: 3, change: 2]
  import Plug.Conn, only: [put_session: 3, get_session: 2, delete_session: 2]
  alias Bibliotheca.{Repo, User}

  def check_session_token(conn, user_id) do
    session_token = get_session(conn, :session_token) || nil
    user = Repo.get(User, user_id)
    case Enum.member?(user.sessions, session_token) do
      true -> {:ok, conn}
      _ -> save_session_token(conn, user_id)
    end
  end

  def delete_session_token(conn, user_id) do
    conn = delete_session(conn, :session_token)
    user = Repo.get(User, user_id)
    changeset = user
                  |> change(%{})
                  |> put_change(:sessions, [])
    case Repo.update(changeset) do
      {:ok, _} -> conn
      {:error, _} -> conn
    end
    
  end

  def save_session_token(conn, user_id) do
    token = Ecto.UUID.generate
    conn = put_session(conn, :session_token, token)
    user = Repo.get(User, user_id)
    #cond do
      #Enum.count(user.sessions) < 2 ->
        sessions = Enum.into(user.sessions, [token])
        changeset = user
                  |> change(%{})
                  |> put_change(:sessions, sessions)
        case Repo.update(changeset) do
          {:ok, _} -> {:ok, conn}
          {:error, _} -> :error
        end
      #:else ->
      #  {:error, :sessions_full}
    #end
  end

end