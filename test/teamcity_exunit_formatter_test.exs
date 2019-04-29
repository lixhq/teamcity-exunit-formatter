defmodule TeamCityExUnitFormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias TeamCityExUnitFormatter, as: Sut
  def config do
    %{
      seed: 1,
      trace: false,
      width: 80,
      tests_counter: 0,
      failures_counter: 0,
      skipped_counter: 0,
      invalids_counter: 0
    }
  end

  test "format test case started" do
    evt = {:case_started, %ExUnit.TestCase{name: "testcase1"}}
    assert_format evt, "##teamcity[testSuiteStarted name='testcase1' flowId='testcase1']"
  end

  test "format test case finished" do
    evt = {:case_finished, %ExUnit.TestCase{name: "testcase1"}}
    assert_format evt, "##teamcity[testSuiteFinished name='testcase1' flowId='testcase1']"
  end

  test "format test started" do
    evt = {:test_started, %ExUnit.Test{name: "test1", case: "testcase1"}}
    assert_format evt, "##teamcity[testStarted name='testcase1.test1' flowId='testcase1']"
  end

  test "format test finished" do
    evt = {:test_finished, %ExUnit.Test{name: "test1", case: "testcase1", time: 40000}}
    assert_format evt, "##teamcity[testFinished name='testcase1.test1' duration='40' flowId='testcase1']"
  end

  test "format skipped test" do
    evt = {:test_finished, %ExUnit.Test{name: "test1", case: "testcase1", state: {:skip, ""}}}
    assert capture_io(fn ->
      Sut.handle_event(evt, config())
    end) == """
    ##teamcity[testIgnored name='testcase1.test1' flowId='testcase1']
    ##teamcity[testFinished name='testcase1.test1' flowId='testcase1']
    """
  end

  test "format failed test" do
    failure = {:error, catch_error(raise "oops"), []}
    failure = if Version.match?(System.version, "~> 1.2") do
      [failure]
    else
      failure
    end

    tags = [file: __ENV__.file, line: 1]
    evt = {:test_finished, %ExUnit.Test{name: "test1", tags: tags, case: "testcase1", state: {:failed, failure}}}
    res = capture_io(fn -> Sut.handle_event(evt, config()) end)
    assert res =~ "##teamcity[testFailed name='testcase1.test1' message='%RuntimeError{message: \"oops\"}' details='"
  end

  test "values are escaped" do
    chars_to_escape = %{
      "'" => "|'", "\n" => "|n", "\r" => "|r", "\u1234" => "\u1234",
      "\u1234'" => "\u1234|'", "|" => "||", "[" => "|[", "]" => "|]"}
    Enum.each chars_to_escape, fn {k, v} ->
      evt = {:case_started, %ExUnit.TestCase{name: "Escape#{k} this"}}
      assert_format evt, "##teamcity[testSuiteStarted name='Escape#{v} this' flowId='Escape#{v} this']"
    end
  end

  defp assert_format(evt, res) do
    assert capture_io(fn ->
      Sut.handle_event(evt, config())
    end) == """
    #{res}
    """
  end
end
