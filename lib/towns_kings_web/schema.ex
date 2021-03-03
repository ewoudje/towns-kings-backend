defmodule TownsKingsWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern
  import_types TownsKingsWeb.Schema.ContentTypes

  alias TownsKingsWeb.Resolvers

  query [name: "Query"] do

    @desc "Get all worlds"
    field :worlds, list_of(:world) do
      resolve &Resolvers.World.list_worlds/3
    end

    field :towns, list_of(:town) do
      arg :world, non_null(:id)
      resolve &Resolvers.Town.list_towns/3
    end

  end

end