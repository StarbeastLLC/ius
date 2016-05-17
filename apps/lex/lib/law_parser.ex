defmodule Lex.LawParser do
  @docmodule """
  This parser takes into account the following file content structure:

  LEY = TITULO_LEY ENCABEZADO PRELIMINAR BODY TRANSITORIOS
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

  alias Lex.{PreliminarParser, BodyParser, TransitoriesParser}

  ###################################################################
  # Función principal de inicio del parseo del contenido del archivo
  ###################################################################
  def parse_file(file_name, nested \\ true) do
    {title, header, preliminar, body_list, transitories, content, content_table} = parse_sections_from_file(file_name, nested)
    reform_date = parse_reform_date(header)
    preliminar_map = PreliminarParser.parse_preliminar(preliminar)
    transitories_map = TransitoriesParser.parse_transitories(transitories)
    {:ok, %{title: title,
            reform_date: reform_date,
            header: header,
            preliminar: preliminar_map,
            body: body_list,
            transitories: transitories_map,
            original_text: content,
            content_table: content_table}}
  end

  ####################
  # Private functions
  ####################
  defp parse_sections_from_file(file_name, nested) do
    {title, content} = parse_content(file_name)
    IO.puts title
    {header, body} = parse_header_body(content, title)

    {preliminars, body, transitories, content_table} =
    if nested do
      BodyParser.parse_nested_body(body)
    else
      BodyParser.parse_body_containing_articles(body, title)
    end

    {title, header, preliminars, body, transitories, content, content_table}
  end

  # Al leer el contenido del archivo aprovechamos para obtener el titulo de la ley.
  # Este titulo nos va a servir despues para separar el encabezado del cuerpo de la ley.
  defp parse_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    # Algunas leyes tienen asteriscos en el primer titulo pero no en el segundo. Ejem. LEY DE AGUAS NACIONALES
    title_begin = IO.read(file, :line)
            |> String.replace("\*", "")
            # |> String.strip

    title_end = IO.read(file, :line)
    title = title_begin <> title_end

    content = IO.read(file, :all)
    {title,content}
  end

  # Dividimos el contenido del archivo en encabezado y cuerpo. El titulo de la ley sirve como divisor.
  defp parse_header_body(content, complete_title) do

    remove_firstline = false
    title = String.split(complete_title, "\n", parts: 2, trim: true)
    if Enum.count(title) == 2 do
      [title, _]= title
      remove_firstline = true
    else
      [title] = title
    end
    title = String.strip(title)

    content = remove_accent_from_text(content)
    title = remove_accent_from_text(title)
    result =
    case String.split(content, title, parts: 2, trim: true) do
      [header, body] ->
        {String.strip(header), String.strip(body)}
      _otro ->
        # En algunos documentos el titulo trae acentos pero el mismo titulo en el cuerpo del documento no.
        # Por lo tanto tenemos que probar quitando los acentos.
        title = remove_accent_from_text(title)

        # result = String.split(content, title, parts: 2, trim: true)
        # IO.puts title
        # IO.inspect Enum.count(result)

        case String.split(content, title, parts: 2, trim: true) do
          [header, body] ->
            {String.strip(header), String.strip(body)}
          _porarticulo ->
            parse_header_body_new(content)
        end
    end

    # if remove_firstline do
    #   {header, body} = result
    #   [_, body] = String.split(body, "\n", parts: 2)
    #   result  = {header, body}
    # end

    result
  end

  def remove_accent_from_text(text) do
    text = String.replace(text, "Á", "A")
    text = String.replace(text, "É", "E")
    text = String.replace(text, "Í", "I")
    text = String.replace(text, "Ó", "O")
    String.replace(text, "Ú", "U")
  end

  defp parse_header_body_new(content) do
    content = String.replace(content, "ARTICULO", "Artículo", global: true)
    [header, body] = String.split(content, "Artículo", parts: 2, trim: true)
    {String.strip(header), String.strip(body)}
  end

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

end
