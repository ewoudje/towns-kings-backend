require WorkList
WorkList.define TKPlayer do

  redis :player,
        [
          {:self, [:name, :town]}
        ]

end
