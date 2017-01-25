TeamCityExUnitFormatter
=======================

See https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity#BuildScriptInteractionwithTeamCity-ServiceMessages

## Installation

First, add TeamCityExUnitFormatter to your `mix.exs` dependencies:

```elixir
def deps do
  [{:teamcity_exunit_formatter, "~> 0.3.0"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Usage

Add this to your `test_helper.exs`:

```elixir
if System.get_env("TEAMCITY_VERSION") do
  ExUnit.configure formatters: [TeamCityExUnitFormatter]
end

ExUnit.start
```
