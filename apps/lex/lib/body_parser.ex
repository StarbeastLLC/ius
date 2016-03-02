defmodule Lex.BodyParser do
  @moduledoc "BODY = (LIBRO+ | TITULO+)"

  import Lex.BookParser, only: [parse_book: 1, book_expression: 0]
  import Lex.TitleParser, only: [parse_title: 1, title_expression: 0]
  import Lex.ArticleParser, only: [parse_article: 2, article_expression: 0]

  # Se recibe el contenido del archivo sin el header.
  def parse_nested_body(body) do
    parse_body_containing(body, body_has(body))
  end

  def parse_body(body) do
    {preliminars, raw_articles, transitories} = parse_body_containing_articles(body)
    {preliminars, raw_articles, transitories}
  end

  ####################
  # Private functions
  ####################
  defp parse_body_containing(body, :books) do
    raw_books = String.split(body, book_expression, trim: true)

    {preliminars, books, transitories} = extract_elements(raw_books)
    books = Enum.with_index(books)
    books_map = Enum.map(books, &parse_book(&1))
    {preliminars, books_map, transitories}
  end

  defp parse_body_containing(body, :titles) do
    raw_titles = String.split(body, title_expression, trim: true)

    {preliminars, titles, transitories} = extract_elements(raw_titles)
    titles = Enum.with_index(titles)
    titles_map = Enum.map(titles, &parse_title(&1))
    {preliminars, titles_map, transitories}
  end

  defp parse_body_containing(body, :articles) do
    body = String.replace(body, "ARTICULO", "Artículo", global: true)
    raw_articles = String.split(body, article_expression, trim: true)

    {preliminars, articles, transitories} = extract_elements(raw_articles)
    articles_map = Enum.reduce(articles, %{}, &parse_article(&1, &2))
    {preliminars, articles_map, transitories}
  end

  defp parse_body_containing(_body, value) do
    IO.puts "Parsing Error: body #{value}"
    {"",%{},""}
  end

  defp parse_body_containing_articles(body) do
    body = String.replace(body, "ARTICULO", "Artículo", global: true)
    body = String.replace(body, "ARTÍCULO", "Artículo", global: true)
    {raw_articles, transitories} = extract_transitories(body)
    articles = String.split(raw_articles, article_expression, trim: true)
    articles_map = Enum.reduce(articles, %{}, &parse_article(&1, &2))
    {"", articles_map, transitories}
  end

  defp extract_transitories(body) do
    raw_transitories = String.split(body, ~r{(\nTransitorios|\nTRANSITORIOS|\s\sTRANSITORIOS)}, parts: 2, trim: true)
    if length(raw_transitories) == 1 do
      {List.first(raw_transitories), ""}
    else
      {List.first(raw_transitories), List.last(raw_transitories)}
    end
  end

  defp extract_elements(raw_elements) do
    {preliminars, body_with_trans} = parse_preliminars(raw_elements)
    {transitories, raw_body} =
    if body_with_trans != nil do
      parse_transitories(body_with_trans)
    else
      {"", []}
    end

    {preliminars, raw_body, transitories}
  end

  defp body_has(body) do
    cond do
      Regex.match?(book_expression, body)  -> :books
      Regex.match?(title_expression, body) -> :titles
      Regex.match?(~r{^ARTICULO}, body)     -> :articles
      true -> :unknown
    end
  end

  defp parse_preliminars(raw_books) do
    first_elem = hd(raw_books)
    preliminars = ""
    raw_preliminars = String.split(first_elem, ~r{(Disposiciones Preliminares)}, parts: 2, trim: true)
    books_without_pre =
    if length(raw_preliminars) == 2 do
      preliminars = raw_preliminars
                    |> Enum.at(1)
                    |> String.strip
      Enum.drop(raw_books,1)
    else
      raw_books
    end

    {preliminars, books_without_pre}
  end

  defp parse_transitories(raw_books) do
    last_elem_index = length(raw_books) - 1
    last_elem = Enum.at(raw_books, last_elem_index)
    raw_transitories = String.split(last_elem, ~r{(Transitorios|TRANSITORIOS)}, parts: 2, trim: true)

    transitories = ""
    # Si hay mas de un elemento significa que hay transitorios, el split encontro la cadena
    # y pudo hacer la separación.
    if length(raw_transitories) == 2 do
      # Primero, de raw_transitories obtenemos y eliminamos el primer elemento que es parte del raw_books.
      [book | transitories] = raw_transitories
      transitories = hd(transitories)

      # El último elemento de raw_books tiene parte del libro y parte de transitorios,
      # por lo que hay que que reemplazar este elemento con uno que no traiga los transitorios.
      raw_books = List.replace_at(raw_books,last_elem_index, book)
    end
    {String.strip(transitories), raw_books}
  end
end
