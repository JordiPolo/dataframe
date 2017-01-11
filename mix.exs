defmodule Dataframe.Mixfile do
  use Mix.Project

  def project do
    [app: :dataframe,
     version: "0.3.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),
     dialyzer: [plt_add_deps: :transitive]
   ]
  end

  defp description do
    """
    Implementation of R's data.frame() or Python's Pandas for Elixir.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Jordi Polo Carres"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/jordipolo/dataframe"}]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:explot, "~> 0.1.0"},
      {:csv, "~> 1.4.2"},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:dialyxir, "~> 0.3", only: [:dev]},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end
end
