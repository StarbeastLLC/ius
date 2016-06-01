defmodule Bibliotheca.AsciiTableParserService do
  def parse_table(text) do
    text
    |> monospace_font
    |> bold_table
  end

  defp monospace_font(text) do
    open_span = "<span style=\"font-family: monospace;\">"
    end_span = "</span>"
    text
    |> String.replace_prefix(~r(+---), open_span <> "+---")
    |> String.replace_suffix(~r(---+), "---+" <> end_span)
  end

  defp bold_table(text) do
    open_bold = "<strong>"
    end_bold = "</strong>"
    text
    |> String.replace("|", open_bold <> "|" <> end_bold)
    |> String.replace("+", open_bold <> "+" <> end_bold)
    |> String.replace("-", open_bold <> "-" <> end_bold)
  end
end
