defmodule TownsKingsWeb.Resolvers.World do

  def list_worlds(parent, _args, resolution) do
    worlds = TownsKings.Repo.World.worlds()

    {:ok, Enum.map(worlds, fn w -> world(parent, %{id: w}, resolution) end) }
  end

  def world(parent, %{id: id}, resolution) do
    Enum.into resolution.definition.selections, %{id: id},
      fn
        %{schema_node: %{identifier: :id}} -> {:id, id}
        res = %{schema_node: %{identifier: :towns}} -> {:towns, TownsKingsWeb.Resolvers.Town.list_towns(parent, %{id: id}, %{definition: res})}
        %{schema_node: %{identifier: name}} -> {name, TownsKings.Repo.World.get(id, name)}
      end
  end

end