defmodule LexTest do
  use ExUnit.Case
  doctest Lex

  @tag :skip
  test "the truth" do
    assert 1 + 1 == 2
  end
end
