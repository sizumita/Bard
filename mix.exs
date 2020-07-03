defmodule Bard.MixProject do
  use Mix.Project

  def project do
    [
      app: :bard,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bard, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:alchemy, git: "https://github.com/sizumita/alchemy.git"},
      {:google_api_text_to_speech, "~> 0.7"},
      {:goth, "~> 1.2.0"},
      {:mongodb, "~> 0.5.1"}
    ]
  end
end
