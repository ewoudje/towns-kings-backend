require WorkList
WorkList.define TKPlotCategory do

  redis :plotcategory,
        [
          {:self, [:name, :town, :priority]}
        ]


  job create(name, town, priority) do
    !self.name = name
    !self.town = town
    !self.priority = priority

    !TKTown.(town).plot_categories =+ {name, @self}

    #Map into chunks
  end

  job destroy() do
    #Redis.del("pos:#{!self.x}:#{!self.y}:#{!self.z}")
    destroy(@self)
  end
end
