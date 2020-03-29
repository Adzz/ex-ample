defmodule Example do
  @moduledoc """
  A module to generate a static site out of the elixir examples in the lib/examples/ directory.
  This module is very hacky but it works.

  If you add a code example in examples, then run Example.build_all/0 the example will be
  automatically included as a page on the static generated site with code highlighting.
  """
  require Makeup.Styles.HTML.StyleMap
  alias Makeup.Styles.HTML.StyleMap

  @templates_dir "lib/templates/"
  @output_dir "lib/output/"
  @code_examples_dir "lib/code_examples/"
  @explanations_dir "lib/explanations/"
  @temp_dir "tmp/"
  @doc """
  Regenerates everything from scratch

  We should only do that after everything else works.
  """
  def build_all do
    # Just in case...
    File.rm_rf!(Path.expand(@temp_dir))
    File.mkdir!(@temp_dir)

    generate_index()
    generate_styles()

    # Check each example has an explanation:
    explanations =
      File.ls!(Path.expand(@explanations_dir))
      |> Enum.map(fn explanation -> drop_extension(explanation, ".html") end)

    examples =
      File.ls!(Path.expand(@code_examples_dir))
      |> Enum.map(fn example -> drop_extension(example, ".ex") end)

    # Perf is bad here but whatever until it matters aye!
    examples
    |> Enum.map(fn example ->
      with explanation when not is_nil(explanation) <-
             Enum.find(explanations, fn explanation -> example == explanation end) do
        explanation
      else
        nil ->
          raise "You need example code in code_examples and an " <>
                  "explanation in explanations and they need to be named the same"
      end
    end)

    File.read!(Path.expand("lib/examples_order.txt"))
    |> String.split("\n")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> next_previous_links()
    |> Enum.map(fn
      # This is when there is only one example
      {:first, [current]} -> build_example(current, [])
      {:first, [current, next]} -> build_example(current, next: next)
      {:last, [previous, current]} -> build_example(current, previous: previous)
      {:middle, [prev, current, next]} -> build_example(current, previous: prev, next: next)
    end)

    # If everything above worked out okay then let's move everything over from tmp
    File.rm_rf!(Path.expand(@output_dir))
    File.mkdir!(@output_dir)
    File.cp_r!(@temp_dir, @output_dir)
    File.rm_rf!(Path.expand(@temp_dir))
    IO.inspect("SUCESS!")
  end

  defp build_example(file_name, next_prev_links) do
    File.touch!(@output_dir <> "#{file_name}.html")

    code_string =
      File.read!(Path.expand(@code_examples_dir <> "#{file_name}.ex"))
      |> Code.format_string!()
      |> Enum.join()

    explanation = File.read!(Path.expand(@explanations_dir <> "#{file_name}.html"))
    code_html = Makeup.highlight(code_string)

    data = code_example_template(explanation, code_html, code_string, next_prev_links)

    generate(%{
      sources: [
        file: "head.html",
        data: data,
        file: "footer.html"
      ],
      destination: "#{file_name}.html"
    })
  end

  def generate_styles() do
    generate(%{
      sources: [data: Makeup.stylesheet(StyleMap.tango_style())],
      destination: "code_highlight.css"
    })

    generate(%{sources: [file: "styles.css"], destination: "styles.css"})
  end

  def generate_index() do
    generate(%{
      sources: [
        file: "head.html",
        file: "index.html",
        data: generate_examples_contents_page(),
        data: "</ul>",
        file: "footer.html"
      ],
      destination: "index.html"
    })
  end

  defp generate_examples_contents_page() do
    File.read!(Path.expand("lib/examples_order.txt"))
    |> String.split("\n")
    |> Enum.filter(fn
      "" -> false
      _ -> true
    end)
    |> Enum.map(fn example ->
      """
      <li><a href="./#{example}.html">#{String.replace(example, "_", " ")}</a></li>
      """
    end)
  end

  defp generate(%{destination: destination, sources: sources}) do
    File.open!(Path.expand(@temp_dir <> destination), [:append], fn destination ->
      Enum.each(sources, fn
        {:file, source} ->
          data = File.read!(Path.expand(@templates_dir <> source))
          IO.binwrite(destination, data)

        {:data, data} ->
          IO.binwrite(destination, data)
      end)
    end)
  end

  def next_previous_links(enum) do
    last_index = length(enum) - 1

    Enum.with_index(enum)
    |> Enum.reduce([], fn {x, index}, acc ->
      case index do
        0 ->
          # first first and index + 1
          acc ++ [first: Enum.take(enum, 2)]

        ^last_index ->
          # last - get last and index - 1
          acc ++ [last: [Enum.at(enum, -2), Enum.at(enum, -1)]]

        index ->
          acc ++ [middle: [Enum.at(enum, index - 1), x, Enum.at(enum, index + 1)]]
      end
    end)
  end

  def drop_extension(name, extension) do
    [file, _extension] = String.split(name, extension)
    file
  end

  defp code_example_template(code_explanation, code_html, code_string, []) do
    """
    <section class="page-wrapper">
      <div class="explanation">
        <h1 class="example-heading"><a href="./">Elixir by Example</a></h1>
        #{code_explanation}
      </div>
      <div class="code-example" id="code-example">
        <button class="copy-btn" role="button">Copy to clipboard</button>
        #{code_html}
      </div>
    </section>
    <script>
    // Used for the copy to clipboard button.
    var code = `#{code_string}`
    </script>
    """
  end

  defp code_example_template(code_explanation, code_html, code_string, next: next_link) do
    """
    <section class="page-wrapper">
      <div class="explanation">
        <h1 class="example-heading"><a href="./">Elixir by Example</a></h1>
        #{code_explanation}
      </div>
      <div class="code-example" id="code-example">
        <button class="copy-btn" role="button">Copy to clipboard</button>
        #{code_html}
      </div>
    </section>
    <section class="footer-btns">
      <a href="#" style="visibility: hidden" class="prev">Previous</a>
      <a href="./#{next_link}.html" class="next">Next</a>
    </section>
    <script>
    // Used for the copy to clipboard button.
    var code = `#{code_string}`
    </script>
    """
  end

  defp code_example_template(code_explanation, code_html, code_string, previous: previous_link) do
    """
    <section class="page-wrapper">
      <div class="explanation">
        <h1 class="example-heading"><a href="./">Elixir by Example</a></h1>
        #{code_explanation}
      </div>
      <div class="code-example" id="code-example">
        <button class="copy-btn" role="button">Copy to clipboard</button>
        #{code_html}
      </div>
    </section>
    <section class="footer-btns">
      <a href="./#{previous_link}.html" class="prev">Previous</a>
    </section>
    <script>
    // Used for the copy to clipboard button.
    var code = `#{code_string}`
    </script>
    """
  end

  defp code_example_template(code_explanation, code_html, code_string,
         previous: previous_link,
         next: next_link
       ) do
    """
    <section class="page-wrapper">
      <div class="explanation">
        <h1 class="example-heading"><a href="./">Elixir by Example</a></h1>
        #{code_explanation}
      </div>
      <div class="code-example" id="code-example">
        <button class="copy-btn" role="button">Copy to clipboard</button>
        #{code_html}
      </div>
    </section>
    <section class="footer-btns">
      <a href="./#{previous_link}.html" class="prev">Previous</a>
      <a href="./#{next_link}.html" class="next">Next</a>
    </section>
    <script>
    // Used for the copy to clipboard button.
    var code = `#{code_string}`
    </script>
    """
  end
end
