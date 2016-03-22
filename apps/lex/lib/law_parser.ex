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
    {title, header, preliminar, body_list, transitories, content} = parse_sections_from_file(file_name, nested)
    reform_date = parse_reform_date(header)
    preliminar_map = PreliminarParser.parse_preliminar(preliminar)
    transitories_map = TransitoriesParser.parse_transitories(transitories)
    {:ok, %{title: title,
            reform_date: reform_date,
            header: header,
            preliminar: preliminar_map,
            body: body_list,
            transitories: transitories_map,
            original_text: content}}
  end

  ####################
  # Private functions
  ####################
  defp parse_sections_from_file(file_name, nested) do
    {title, content} = parse_content(file_name)
    IO.puts title
    {header, body} = parse_header_body_new(content)

    {preliminars, body, transitories} =
    if nested do
      BodyParser.parse_nested_body(body)
    else
      BodyParser.parse_body(body)
    end

    {title, header, preliminars, body, transitories, content}
  end

  # Al leer el contenido del archivo aprovechamos para obtener el titulo de la ley.
  # Este titulo nos va a servir despues para separar el encabezado del cuerpo de la ley.
  defp parse_content(file_name) do
    {:ok, file} = File.open(file_name, [:read, :utf8])
    # Algunas leyes tienen asteriscos en el primer titulo pero no en el segundo. Ejem. LEY DE AGUAS NACIONALES
    title = IO.read(file, :line)
            |> String.replace("\*", "")
            |> String.strip

    content = IO.read(file, :all)
    {title,content}
  end

  # Dividimos el contenido del archivo en encabezado y cuerpo. El titulo de la ley sirve como divisor.
  defp parse_header_body(content, title) do
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
