defmodule Lex.ArticleParser do
  @docmodule "ARTICULO = NUMERO TEXTO"

  @article_expression ~r{\n\s\s\sArtículo\s}
  @article_number_expression ~r{(\.-|\.|:|\n)}

  ####################
  # Public functions
  ####################
  def parse_article(article, acc \\ %{}) do
    parse_article_containing(article, acc, :text)
  end

  def article_expression, do: @article_expression

  ####################
  # Branchs
  ####################
  defp parse_article_containing(article, acc, :text) do
    raw_article = split_article_using(article, @article_number_expression)
    {article_number, raw_text} = extract_article_number(raw_article)
    unless raw_text == nil do
      text = clean_text(raw_text)
      key = "ARTICULO " <> article_number
      acc = [{key, text} | acc]
    end

    acc
  end

  ####################
  # Private functions
  ####################
  defp split_article_using(article, expression) do
    article
    |> String.strip
    |> String.split(expression, trim: true, parts: 2)
  end

  defp extract_article_number(raw_element) do
    article_number = raw_element
    |> Enum.at(0)
    |> String.strip

    elements = raw_element |> Enum.drop(1)
    {article_number, Enum.at(elements, 0)}
  end

  defp clean_text(raw_text) do
    expression = expression_to_split(raw_text)
    raw_articles = String.split(raw_text, expression, trim: true)
    List.first(raw_articles)
  end

  defp expression_to_split(raw_text) do
    book_expression = ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    title_expression = ~r{TITULO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    transitories_expression = ~r(\s\s\sTRANSITORIO\n|\s\s\sTRANSITORIOS\n)
    article_expression = ~r{NADA_FACTIBLE_DE_ENCONTRAR}
    chapter_expression = ~r{CAPITULO (UNICO|PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO|I|II|III|IV|V|VI|VII|VIII|IX|X)}

    cond do
      Regex.match?(book_expression, raw_text)         -> book_expression
      Regex.match?(title_expression, raw_text)        -> title_expression
      Regex.match?(transitories_expression, raw_text) -> transitories_expression
      Regex.match?(chapter_expression, raw_text) -> chapter_expression
      true -> article_expression
    end
  end
end
