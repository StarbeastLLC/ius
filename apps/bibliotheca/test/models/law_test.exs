defmodule Bibliotheca.LawTest do
  use Bibliotheca.ModelCase

  alias Bibliotheca.Law

  @valid_attrs %{header: "some content", name: "some content", original_text: "some content", reform_date: "2010-04-17", json_text: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Law.changeset(%Law{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Law.changeset(%Law{}, @invalid_attrs)
    refute changeset.valid?
  end
end
