defmodule MapDelta.Composition do
  @moduledoc """
  Map deltas composition.
  """

  alias MapDelta.{Operation, Iterator, ItemDelta}

  def compose(%MapDelta{ops: ops_a}, %MapDelta{ops: ops_b}) do
    ops_a
    |> Iterator.iterate(ops_b, &do_compose/1)
    |> wrap_into_delta()
  end

  defp do_compose({op_a, nil}) do
    [op_a]
  end

  defp do_compose({nil, op_b}) do
    [op_b]
  end

  defp do_compose({%{add: _}, %{add: _} = add_b}) do
    [add_b]
  end

  defp do_compose({%{add: _}, %{remove: _}}) do
    []
  end

  defp do_compose({%{add: prop}, %{replace: _, init: init}}) do
    [Operation.add(prop, init)]
  end

  defp do_compose({%{add: prop, init: init}, %{change: _, delta: delta}}) do
    [Operation.add(prop, ItemDelta.compose(init, delta))]
  end

  defp do_compose({%{replace: prop, init: init}, %{change: _, delta: delta}}) do
    [Operation.replace(prop, ItemDelta.compose(init, delta))]
  end

  defp do_compose({%{change: prop, delta: delta_a},
                   %{change: _, delta: delta_b}}) do
    [Operation.change(prop, ItemDelta.compose(delta_a, delta_b))]
  end

  defp do_compose({%{remove: _} = remove, %{change: _}}) do
    [remove]
  end

  defp do_compose({_, %{add: prop, init: init}}) do
    [Operation.replace(prop, init)]
  end

  defp do_compose({_, %{remove: _} = remove}) do
    [remove]
  end

  defp do_compose({_, %{replace: _} = replace}) do
    [replace]
  end

  defp wrap_into_delta(ops), do: %MapDelta{ops: ops}
end
