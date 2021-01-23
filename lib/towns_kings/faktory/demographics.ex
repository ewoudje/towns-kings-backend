require WorkList
WorkList.define TKDemographic do

  redis :demographic,
        [
          {:self, [:name, :town]}
        ]


  job update() do

  end
end
