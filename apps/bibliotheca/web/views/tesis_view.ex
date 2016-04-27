defmodule Bibliotheca.TesisView do
  use Bibliotheca.Web, :view

  def separate_amparos(precedentes) do
    String.replace(precedentes, "Amparo en revisión ", "<br><b>Amparo en revisión</b><br>")
  end
end
