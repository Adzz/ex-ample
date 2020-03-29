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
