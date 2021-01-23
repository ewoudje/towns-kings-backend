require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.World do

  redis :world,
        [
          {:self, [:name]},
          {:towns, :hset}
        ]


end

