defmodule TeamCityExUnitFormatter do
  @moduledoc false

  use GenServer

  import ExUnit.Formatter,
    only: [format_test_failure: 5]

  def formatter(_color, msg), do: msg

  def init(opts) do
    config = %{
      seed: opts[:seed],
      trace: opts[:trace],
      width: 80,
      tests_counter: 0,
      failures_counter: 0,
      skipped_counter: 0,
      invalids_counter: 0
    }
    {:ok, config}
  end

  def handle_cast({:case_started, %ExUnit.TestCase{name: name}}, config) do
    IO.puts format :test_suite_started, name: name, flowId: name
    {:noreply, config}
  end

  def handle_cast({:case_finished, %ExUnit.TestCase{name: name}}, config) do
    IO.puts format :test_suite_finished, name: name, flowId: name
    {:noreply, config}
  end

  def handle_cast({:test_started, %ExUnit.Test{name: name, case: the_case}}, config) do
    IO.puts format :test_started, name: "#{the_case}.#{name}", flowId: the_case
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{name: name, case: the_case, time: time, state: {:failed, {_, reason, _} = failed}} = test}, config) do
    formatted = format_test_failure(test, failed, config.failures_counter + 1, config.width, &formatter/2)
    IO.puts format :test_failed, name: "#{the_case}.#{name}", message: inspect(reason), details: formatted, flowId: the_case
    IO.puts format :test_finished, name: "#{the_case}.#{name}", duration: div(time, 1000), flowId: the_case
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{name: name, case: the_case, time: time, state: {:failed, failed}} = test}, config) when is_list(failed) do
    formatted = format_test_failure(test, failed, config.failures_counter + 1, config.width, &formatter/2)

    message = Enum.map_join(failed, "", fn {_kind, reason, _stack} -> inspect(reason) end)
    IO.puts format :test_failed, name: "#{the_case}.#{name}", message: message, details: formatted, flowId: the_case
    IO.puts format :test_finished, name: "#{the_case}.#{name}", duration: div(time, 1000), flowId: the_case
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{name: name, case: the_case, state: {:skip, _}}}, config) do
    IO.puts format :test_ignored, name: "#{the_case}.#{name}", flowId: the_case
    IO.puts format :test_finished, name: "#{the_case}.#{name}", flowId: the_case
    {:noreply, config}
  end

  def handle_cast({:test_finished, %ExUnit.Test{name: name, case: the_case, time: time}}, config) do
    IO.puts format :test_finished, name: "#{the_case}.#{name}", duration: div(time, 1000), flowId: the_case
    {:noreply, config}
  end

  def handle_cast(_, config) do
    {:noreply, config}
  end

  defp format(type, attributes) do
    attrs = attributes
            |> Enum.map(&format_attribute/1)
            |> Enum.join(" ")
    messageName = camelize Atom.to_string(type)
    "##teamcity[#{messageName} #{attrs}]"
  end

  defp format_attribute({k, v}) do
    "#{Atom.to_string k}='#{escape_output v}'"
  end

  defp camelize(s) do
    [head | tail] = String.split s, "_"
    "#{head}#{Enum.map tail, &String.capitalize/1}"
  end

   #Must escape certain characters, see: https://confluence.jetbrains.com/display/TCD9/Build+Script+Interaction+with+TeamCity
  defp escape_output(s) when not is_binary(s) do escape_output("#{s}") end
  defp escape_output(s) do
    s
      |> String.replace("|", "||")
      |> String.replace("'", "|'")
      |> String.replace("\n", "|n")
      |> String.replace("\r", "|r")
      #|> String.replace(~r/u([0-9a-f]{4})/i, "|0x\\1")
      #|> String.replace(~r/\x{([0-9a-f]{4})}/ui, "|0x\\1")
      |> String.replace("[", "|[")
      |> String.replace("]", "|]")
  end
end
