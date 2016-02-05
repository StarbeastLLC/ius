defmodule Bibliotheca.UserTest do
  use Bibliotheca.ModelCase

  alias Bibliotheca.User

  @valid_attrs %{email: "some content", first_name: "some content", is_verified: true, last_name: "some content", password: "some content", username: "some content", verification_token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
