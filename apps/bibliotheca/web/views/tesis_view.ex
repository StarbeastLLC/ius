defmodule Bibliotheca.TesisView do
  use Bibliotheca.Web, :view

  def separate_amparos(precedentes) do
    terms = [
            "Amparo directo en revisión",
            "Amparo directo",
            "Amparo en revisión",
            "Amparo indirecto en revisión",
            "Amparo indirecto",
            "Contradicción de tesis",
            "Acción de inconstitucionalidad"
            ]
    Enum.reduce(terms, precedentes, fn(term, precedentes) ->
      styled_term = "<br><b>#{term}</b><br>"
      String.replace(precedentes, term, styled_term)
    end)
  end
end
