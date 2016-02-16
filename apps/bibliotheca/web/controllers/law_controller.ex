defmodule Bibliotheca.LawController do
  use Bibliotheca.Web, :controller

  alias Bibliotheca.Law
  alias Lex.LawParser

  plug :scrub_params, "law" when action in [:create, :update]

  def index(conn, _params) do
    laws = Repo.all(Law)
    render(conn, "index.html", laws: laws)
  end

  def load(conn, _params) do
    {:ok, files} = File.ls("docs/federales")
    # export_file("2_241213.txt")
    # export_file("100.txt")
    Enum.each(files, &export_file_async(&1))
    # Enum.each(files, &export_file(&1))

    laws = Repo.all(Law)
    render(conn, "index.html", laws: laws)
  end

  defp export_file_async(file) do
    spawn(fn -> export_file(file) end)
  end

  defp export_file(file) do
    IO.puts "Processing file: " <> file
    case LawParser.parse_file("docs/federales/" <> file) do
      {:ok, content} ->
        law = %Law{file_name: file,
                   name: content[:title],
                   header: content[:header],
                   reform_date: content[:reform_date],
                   original_text: content[:original_text],
                   json_text: content}

      Repo.insert(law)
      {:error, error} ->
        IO.puts error
    end
  end

  def new(conn, _params) do
    changeset = Law.changeset(%Law{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"law" => law_params}) do
    changeset = Law.changeset(%Law{}, law_params)

    case Repo.insert(changeset) do
      {:ok, _law} ->
        conn
        |> put_flash(:info, "Law created successfully.")
        |> redirect(to: law_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    law = Repo.get!(Law, id)
    render(conn, "show.html", law: law)
  end

  def edit(conn, %{"id" => id}) do
    law = Repo.get!(Law, id)
    changeset = Law.changeset(law)
    render(conn, "edit.html", law: law, changeset: changeset)
  end

  def update(conn, %{"id" => id, "law" => law_params}) do
    law = Repo.get!(Law, id)
    changeset = Law.changeset(law, law_params)

    case Repo.update(changeset) do
      {:ok, law} ->
        conn
        |> put_flash(:info, "Law updated successfully.")
        |> redirect(to: law_path(conn, :show, law))
      {:error, changeset} ->
        render(conn, "edit.html", law: law, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    law = Repo.get!(Law, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(law)

    conn
    |> put_flash(:info, "Law deleted successfully.")
    |> redirect(to: law_path(conn, :index))
  end
end
