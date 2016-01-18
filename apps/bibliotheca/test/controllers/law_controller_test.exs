defmodule Bibliotheca.LawControllerTest do
  use Bibliotheca.ConnCase

  alias Bibliotheca.Law
  @valid_attrs %{header: "some content", name: "some content", original_text: "some content", reform_date: "2010-04-17", json_text: %{}}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, law_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing laws"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, law_path(conn, :new)
    assert html_response(conn, 200) =~ "New law"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, law_path(conn, :create), law: @valid_attrs
    assert redirected_to(conn) == law_path(conn, :index)
    assert Repo.get_by(Law, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, law_path(conn, :create), law: @invalid_attrs
    assert html_response(conn, 200) =~ "New law"
  end

  test "shows chosen resource", %{conn: conn} do
    law = Repo.insert! %Law{}
    conn = get conn, law_path(conn, :show, law)
    assert html_response(conn, 200) =~ "Show law"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, law_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    law = Repo.insert! %Law{}
    conn = get conn, law_path(conn, :edit, law)
    assert html_response(conn, 200) =~ "Edit law"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    law = Repo.insert! %Law{}
    conn = put conn, law_path(conn, :update, law), law: @valid_attrs
    assert redirected_to(conn) == law_path(conn, :show, law)
    assert Repo.get_by(Law, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    law = Repo.insert! %Law{}
    conn = put conn, law_path(conn, :update, law), law: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit law"
  end

  test "deletes chosen resource", %{conn: conn} do
    law = Repo.insert! %Law{}
    conn = delete conn, law_path(conn, :delete, law)
    assert redirected_to(conn) == law_path(conn, :index)
    refute Repo.get(Law, law.id)
  end
end
