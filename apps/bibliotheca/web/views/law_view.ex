defmodule Bibliotheca.LawView do
  use Bibliotheca.Web, :view

  alias Bibliotheca.{FederalArticle, Repo, ContentsTable}

  def json(map) do
    {:ok, json} = Poison.encode(map)
    json
  end

  def style_section(contents) do
    contents
    |> separate_sections
    |> bold_numbers
  end

  defp separate_sections(section) do
    terms = [
            "TITULO",
            "LIBRO",
            "CAPITULO"
            ]
    Enum.reduce(terms, section, fn(term, section) ->
      styled_term = "<br><b>#{term}</b>"
      String.replace(section, term, styled_term)
    end)
  end

  defp bold_numbers(section) do
    terms = [
            "UNICO", "PRIMERO", "SEGUNDO", "TERCERO", "CUARTO", "QUINTO",
            "SEXTO", "SEPTIMO", "OCTAVO", "NOVENO", "DECIMO",
            "I", "II", "III", "IV", "V",
            "VI", "VII", "VIII", "IX", "X",
            "XI", "XII", "XIII", "XIV", "XV",
            "XVI", "XVII", "XVIII", "XIX", "XX"
            ]
    Enum.reduce(terms, section, fn(term, section) ->
      styled_term = "<b>#{term}</b>"
      String.replace(section, term, styled_term)
    end)
  end
end
