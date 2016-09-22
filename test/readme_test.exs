# Runs all the tests in lesson1
defmodule ReadmeTest do
  use ExUnit.Case, async: true

  test "run it" do
    tutorial_text = File.read!("README.md")
    all_code_in_tutorial =  Enum.join List.flatten Regex.scan(~r/```elixir(.*?)```/s, tutorial_text, capture: :all_but_first)
    Code.eval_string(all_code_in_tutorial)
  end
end
