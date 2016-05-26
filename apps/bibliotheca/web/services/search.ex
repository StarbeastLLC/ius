defmodule Bibliotheca.SearchService do
  import Ecto.Query
  import Ecto.Changeset, only: [put_change: 3, change: 2]
  import Plug.Conn, only: [put_session: 3, get_session: 2, delete_session: 2]
  alias Bibliotheca.{Repo, FederalArticle}

  def clean_search_term(search_term) do
    fts_term = search_term
             |> remove_final_space
             |> search_exact_phrases
             |> remove_and_operator_triplication
             |> parse_or_operator
             |> upcase_unaccent

    like_term = postgres_like_array(search_term)
    [fts_term, like_term]
  end

  def separate_terms(search_term) do
    String.split(search_term, ~r( [&|] ))
  end
  
  defp postgres_like_array(search_term) do
    search_term
    |> upcase_unaccent
    |> String.split(~r( [&|] ))
    |> Enum.map(fn(x) -> ~s(%#{x}%) end)
  end

  def upcase_unaccent(search_term) do
    search_term
    |> String.upcase
    |> String.replace("Á", "A")
    |> String.replace("É", "E")
    |> String.replace("Í", "I")
    |> String.replace("Ó", "O")
    |> String.replace("Ú", "U")
  end

  defp remove_final_space(search_term) do
    if String.ends_with?(search_term, " ") do
      String.replace_suffix(search_term, " ", "")
    else
      search_term
    end
  end

  defp parse_or_operator(search_term) do
    if String.contains?(search_term, "& | &") do
      String.replace(search_term, "& | &", "|")
    else
      search_term
    end
  end

  defp search_exact_phrases(search_term) do
    String.replace(search_term, " ", " & ")
  end

  defp remove_and_operator_triplication(search_term) do
    String.replace(search_term, "& & &", "&")
  end

end
