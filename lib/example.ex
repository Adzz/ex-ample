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

    explanations =
      File.ls!(Path.expand(@explanations_dir))
      |> Enum.map(fn explanation -> drop_extension(explanation, ".html") end)

    examples =
      File.ls!(Path.expand(@code_examples_dir))
      |> Enum.map(fn example -> drop_extension(example, ".ex") end)

    # Perf is bad here but whatever until it matters aye!
    Enum.map(examples, fn example ->
      explanation =
        Enum.find(explanations, fn explanation ->
          example == explanation
        end)

      {explanation, example}
    end)
    |> Enum.each(&build_example/1)

    # If everything above worked out okay then let's move everything over from tmp
    File.rm_rf!(Path.expand(@output_dir))
    File.mkdir!(@output_dir)
    File.cp_r!(@temp_dir, @output_dir)
    "SUCESS!"|> IO.inspect()
  end

  def build_example({explanation, example}) do
    File.touch!(@output_dir <> "#{example}.html")

    code_string =
      File.read!(Path.expand(@code_examples_dir <> "#{example}.ex"))
      |> Code.format_string!()
      |> Enum.join()

    explanation = File.read!(Path.expand(@explanations_dir <> "#{explanation}.html"))

    code_html = Makeup.highlight(code_string)
    data = code_example_template(explanation, code_html, code_string)

    generate(%{
      sources: [
        file: "head.html",
        data: data,
        file: "footer.html"
      ],
      destination: "#{example}.html"
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
        file: "footer.html"
      ],
      destination: "index.html"
    })
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

  defp drop_extension(name, extension) do
    [file, _extension] = String.split(name, extension)
    file
  end

  defp code_example_template(code_explanation, code_html, code_string) do
    """
    <section class="page-wrapper">
      <div class="explanation">
        #{code_explanation}
      </div>
      <div class="code-example" id="code-example">
        <div class="right-column">
        <button class="copy">Copy to clipboard</button>
        #{code_html}
        </div>
      </div>
    </section>
    <script>
    // Used for the copy to clipboard button.
    var code = `#{code_string}`
    </script>
    """
  end
end
