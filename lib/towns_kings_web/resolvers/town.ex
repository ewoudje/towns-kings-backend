defmodule TownsKingsWeb.Resolvers.Town do

  def list_towns(parent, %{world: world}, resolution) do
    towns = TownsKings.Repo.World.towns(world)

    {:ok, Enum.map(towns, fn t -> town(parent, %{id: t}, resolution) end)}
  end

  def town(_parent, %{id: id}, resolution) do
    Enum.into resolution.definition.selections, %{}, fn
      %{schema_node: %{identifier: :id}} -> {:id, id}
      %{schema_node: %{identifier: name}} -> {name, TownsKings.Repo.Town.get(id, name)}
    end
  end

end