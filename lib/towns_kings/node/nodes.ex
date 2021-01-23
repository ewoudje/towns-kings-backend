defmodule Nodes do
  alias __MODULE__

  def def_node(definition) do

  end


  def define_nodes() do
    def_node %{
      name: "allow",
      input: [
        :permission,
        :players
      ],
      execute: fn [permission, players] ->
        #TODO implement this
        {:ok}
      end
    }

    def_node %{
      name: "demographic",
      input: [
        :demographic
      ],
      output: [
        :players
      ],
      execute: fn [permission] ->
        #TODO implement this
        []
      end
    }

    def_node %{
      name: "filter",
      input: [
        :filter,
        :players
      ],
      output: [
        :players
      ],
      execute: fn [filter, players] ->
        #TODO implement this
        players
      end
    }

    def_node %{
      name: "filter-end",
      input: [
        {:funcs, :bool},
        :filter_start
      ],
      output: [
        {:continue, :filter}
      ],
      execute: fn [funcs, start] ->
        #TODO implement this
        {}
      end
    }
  end

end