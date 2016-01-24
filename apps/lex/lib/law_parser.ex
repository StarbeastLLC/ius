defmodule Lex.LawParser do
  @docmodule """

  This parser takes into account the following file content structure:

  LEY = ENCABEZADO TITULO_LEY PRELIMINAR (LIBRO+ | TITULO+) TRANSITORIOS
  PRELIMINAR = ARTICULO+
  LIBRO = (PARTE+ | TITULO+)
  PARTE = TITLE? TITULO+
  TITULO = TITLE ( APARTADO+ | CAPITULO+ | ARTICULO+ )
  APARTADO = TITLE ( SUBAPARTADO+ | CAPITULO+ | ARTICULO+ )
  SUBAPARTADO = TITLE! CAPITULO+
  CAPITULO = TITLE? (SUBTITULO+ | SECCION+ | ARTICULO+)
  SECCION = TITLE ARTICULO+
  ARTICULO = NUMERO TEXTO
  TRANSITORIOS = TRANSITORIO+ DECRETO+ ARTICULO*

  The parser receives a file name and returns a map.

  """

  alias Lex.{BookParser, PreliminarParser, TransitoriesParser}

  ###################################################################
  # Función principal de inicio del parseo del contenido del archivo
  ###################################################################
  def parse_file(file_name) do
    case parse_sections_from_file(file_name) do
      {title, header, preliminar, books, transitories, content} ->
        reform_date = parse_reform_date(header)
        preliminar_map = PreliminarParser.parse_preliminar(preliminar)
        books_map = Enum.map(books, &BookParser.parse_book(&1))
        transitories_map = TransitoriesParser.parse_transitories(transitories)
        {:ok, %{title: title, reform_date: reform_date, header: header, preliminar: preliminar_map, books: books_map, transitories: transitories_map, original_text: content}}
      _otro ->
        {:error, "File with unknown content: " <> file_name}
    end

  end

  ####################
  # Private functions
  ####################
  defp parse_reform_date(header) do
    reform_date = Regex.run(~r{DOF.*}, header)
    if reform_date != nil do
      reform_date
      |> Enum.at(0)
      |> String.split(" ", trim: true)
      |> Enum.at(1)
    else
      "NO TIENE FECHA"
    end
  end

  defp parse_sections_from_file(file_name) do
    {title, content} = parse_content(file_name)
    {header, body} = parse_header_body(content, title)
    {preliminars, books, transitories} = parse_main_sections(body)

    {title, header, preliminars, books, transitories, content}
  end

  defp parse_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    title = IO.read(file, :line) |> String.strip
    content = IO.read(file, :all)
    {title,content}
  end

  defp parse_header_body(content, title) do
    # [header, body] = String.split(content, title, parts: 2, trim: true)
    case String.split(content, title, parts: 2, trim: true) do
      [header, body] ->
        {String.strip(header), String.strip(body)}
      _otro ->
        # En algunos documentos el titulo trae acentos pero el mismo titulo en el cuerpo del documento no.
        # Por lo tanto tenemos que probar quitando los acentos.
        title = String.replace(title, "Á", "A")
        title = String.replace(title, "É", "E")
        title = String.replace(title, "Í", "I")
        title = String.replace(title, "Ó", "O")
        title = String.replace(title, "Ú", "U")
        [header, body] = String.split(content, title, parts: 2, trim: true)
        {String.strip(header), String.strip(body)}
    end
  end

  defp parse_main_sections(body) do
    books_exp = ~r{LIBRO (PRIMERO|SEGUNDO|TERCERO|CUARTO|QUINTO|SEXTO|SEPTIMO|OCTAVO|NOVENO|DECIMO)}
    raw_books = String.split(body, books_exp, trim: true)

    {preliminars, books_with_trans} = parse_preliminars(raw_books)
    {transitories, books} =
    if books_with_trans != nil do
      parse_transitories(books_with_trans)
    else
      {"", []}
    end

    books = Enum.with_index(books)
    {preliminars, books, transitories}
  end

  defp parse_preliminars(raw_books) do
    first_elem = hd(raw_books)
    preliminars = ""
    raw_preliminars = String.split(first_elem, ~r{(Preliminares)}, parts: 2, trim: true)
    books_without_pre =
    if length(raw_preliminars) == 2 do
      preliminars = raw_preliminars
                    |> Enum.at(1)
                    |> String.strip
      Enum.drop(raw_books,1)
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
