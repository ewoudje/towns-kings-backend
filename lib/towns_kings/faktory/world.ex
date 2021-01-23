require WorkList
WorkList.define TKWorld do

  redis :world,
        [
          {:self, [:name]},
          {:towns, :hset}
        ]


end

