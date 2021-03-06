defmodule MapDeltaTest do
  use ExUnit.Case

  doctest MapDelta

  alias MapDelta.Operation

  describe "construct" do
    test "add" do
      assert ops(MapDelta.add("a", nil)) == [Operation.add("a", nil)]
    end

    test "remove" do
      assert ops(MapDelta.remove("a")) == [Operation.remove("a")]
    end

    test "replace" do
      assert ops(MapDelta.replace("a", 2)) == [Operation.replace("a", 2)]
    end

    test "change" do
      assert ops(MapDelta.change("a", 5)) == [Operation.change("a", 5)]
    end

    test "composition of multiple operations" do
      delta =
        MapDelta.new()
        |> MapDelta.add("a", nil)
        |> MapDelta.change("b", 4)
        |> MapDelta.change("a", 3)
        |> MapDelta.remove("b")
        |> MapDelta.change("a", 5)
      assert ops(delta) == [Operation.add("a", 5), Operation.remove("b")]
    end
  end

  defp ops(delta), do: MapDelta.operations(delta)
end
