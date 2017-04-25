defmodule Binary.Mixfile do
  use Mix.Project

  def project do
    [app: :binary,
     version: "0.0.4",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     deps: deps(),
     package: package(),
     docs: [main: "Binary", # The main page in the docs
            extras: ["README.md"]],
     name: "Binary",
     source_url: "https://github.com/comboy/elixir-binary"]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev}]
  end


  defp description do
    """
    Toolkit for handling binaries in Elixir.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :binary,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["comboy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/comboy/elixir-binary"}
    ]
  end
end
