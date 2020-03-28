defmodule ExampleTest do
  use ExUnit.Case
  doctest Example

  test "build_all" do
    Example.build_all()
  end
end
