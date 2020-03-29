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
      existing_code_example =
        File.ls!(Path.expand("lib/code_examples/"))
        |> Enum.map(fn f -> Example.drop_extension(f, ".ex") end)
        |> Enum.find(fn f -> f ==   example_name end)

      existing_code_explanation =
        File.ls!(Path.expand("lib/explanations/"))
        |> Enum.map(fn f -> Example.drop_extension(f, ".html") end)
        |> Enum.find(fn f -> f == example_name end)

      if existing_code_example || existing_code_explanation do
        raise "An example of that name exists already please pick another."
      else
        File.touch!(Path.expand("lib/code_examples/#{example_name}.ex"))
        File.touch!(Path.expand("lib/explanations/#{example_name}.html"))
        "lib/code_examples/#{example_name}.ex created"|> IO.inspect(limit: :infinity)
        "lib/explanations/#{example_name}.html created"|> IO.inspect(limit: :infinity)
      end
    else
      raise "Example names must be snake_case"
    end
  end
end
