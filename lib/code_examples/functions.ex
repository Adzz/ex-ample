upcase = fn letter -> String.upcase(letter) end
# Note the dot before the bracket.
upcase.("a")

Enum.map(["a", "b"], upcase)

defmodule Letter do
  def upcase(letter) do
    String.upcase(letter)
  end
end

Enum.map(["a", "b"], &Letter.upcase/1)
# Or an alternative syntax:
Enum.map(["a", "b"], &Letter.upcase(&1))
# &1 refers to the first argument passed to
# Letter.upcase. If there are more arguments
# you can refer to them like so

defmodule Letter do
  def join_upcase(letter, next_letter) do
    String.upcase(letter <> next_letter)
  end
end

Enum.zip_with(
  ["a", "b"],
  ["c", "d"],
  &Letter.join_upcase(&1, &2)
)
