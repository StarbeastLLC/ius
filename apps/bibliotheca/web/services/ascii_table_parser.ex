defmodule Bibliotheca.AsciiTableParserService do
  defp monospace_font(text) do
    open_span = "<span style=\"font-family: monospace;\">"
    end_span = "</span>"
    text
    |> String.replace(~r(+---), open_span <> "+---")
    |> String.replace(~r(---+), "---+" <> end_span)
  end
end
