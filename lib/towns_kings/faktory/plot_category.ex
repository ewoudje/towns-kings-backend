require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.PlotCategory do

  redis :plotcategory,
        [
          {:self, [:name, :town, :priority]}
        ]


  job create(name, town, priority) do
    !self.name = name
    !self.town = town
    !self.priority = priority

    !Town.(town).plot_categories =+ {name, @self}

    #Map into chunks
  end

  job destroy() do
    #Redis.del("pos:#{!self.x}:#{!self.y}:#{!self.z}")
    redis_destroy(@self)
  end
end
