defmodule TeamcityExunitFormatter.Mixfile do
  use Mix.Project

  def project do
    [app: :teamcity_exunit_formatter,
     version: "0.1.0",
     elixir: "~> 1.0",
     description: "A formatter for Elixirs ExUnit that formats as TeamCity Service Messages. Will let you track test results in TeamCitys UI",
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp package do
    [maintainers: ["Simon Stender Boisen"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/lixhq/teamcity-exunit-formatter"}]
  end

  defp deps do
    []
  end
end
