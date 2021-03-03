require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.World do

  redis :world,
        [
          {:self, [:name]},
          {:towns, :hset}
        ]

  g_prov worlds() do
    {:ok, r} = Redix.command(:redix, ["smembers", "worlds"])

    r
  end

  prov towns() do
    {:ok, r} = Redix.command(:redix, ["hvals", "world:#{@self}:towns"])

    r
  end

end

