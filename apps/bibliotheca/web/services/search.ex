defmodule Bibliotheca.SearchService do
  import Ecto.Query
  import Ecto.Changeset, only: [put_change: 3, change: 2]
  import Plug.Conn, only: [put_session: 3, get_session: 2, delete_session: 2]
  alias Bibliotheca.{Repo, FederalArticle}

  def clean_search_term(search_term) do
    remove_final_space(search_term)
  end

  defp remove_final_space(search_term) do
    if String.ends_with?(search_term, " ") do
      String.replace_suffix(search_term, " ", "")
    else
      search_term
    end 
  end

end