defmodule Mix.Tasks.BuildSite do
  use Mix.Task

  @shortdoc "Generates the static site."

  @doc """
  Generates the static site. Is outputted to docs/ so we can use github pages.
  """
  def run(_) do
    Example.build_all()
  end
end
