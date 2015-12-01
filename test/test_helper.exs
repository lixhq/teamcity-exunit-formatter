formatters = if System.get_env("TEAMCITY") != nil, do: [TeamCityExUnitFormatter], else: [ExUnit.CLIFormatter]
ExUnit.start(formatters: formatters)
