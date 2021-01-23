require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.Demographic do

  redis :demographic,
        [
          {:self, [:name, :town]}
        ]


  job update() do

  end
end
