defmodule TownsKingsWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :world do
    field :id, :id
    field :name, :string
    field :towns, list_of(:town)
  end

  object :town do
    field :id, :id
    field :name, :string
  end
end