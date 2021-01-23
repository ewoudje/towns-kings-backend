require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.Player do

  redis :player,
        [
          {:self, [:name, :town]}
        ]

end
