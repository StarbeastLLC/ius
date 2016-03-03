defmodule Bibliotheca.SessionService do
  import Ecto.Query
  import Ecto.Changeset, only: [put_change: 3, change: 2]
  import Plug.Conn, only: [put_session: 3]
  alias Bibliotheca.{Repo, User}

  def save_session_token(conn, user_id) do
    token = Ecto.UUID.generate
    conn = put_session(conn, :session_token, token)
    user = Repo.get(User, user_id)
    cond do
      Enum.count(user.sessions) < 2 ->
        sessions = Enum.into(user.sessions, [token])
        changeset = user
                  |> change(%{})
                  |> put_change(:sessions, sessions)
        case Repo.update(changeset) do
          {:ok, _} -> {:ok, conn}
          {:error, _} -> :error
        end
      :else ->
        {:error, :sessions_full}
    end
  end

end