defmodule TeamcityExunitFormatter.Mixfile do
  use Mix.Project

  def project do
    [app: :teamcity_exunit_formatter,
     version: "0.5.0",
     elixir: "~> 1.5",
     description: "A formatter for Elixir's ExUnit that formats as TeamCity Service Messages. Will let you track test results in TeamCitys UI",
     package: package(),
     deps: deps()]
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
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
