defmodule Mix.Tasks.NewExample do
  use Mix.Task

  @shortdoc "Accepts an example name, scaffolds the files needed to generate the code"

  @doc """
  Generates two files the from the given example name, an explanation file and an .ex example file.

  ### Example

      $ mix new_example start_a_gen_server

  Will generate a `lib/explanations/start_a_gen_server.html` file
  and a `lib/code_examples/start_a_gen_server.ex` file.
  """
  def run([example_name]) do
    if Regex.match?(~r/^[a-z]+(?:_[a-z]+)*$/, example_name) do
      # Check file doesn't already exist.
      File.touch!(Path.expand("lib/code_examples/#{example_name}.ex"))
      File.touch!(Path.expand("lib/explanations/#{example_name}.html"))
    else
      raise "Example names must be snake_case"
    end
  end
end
