require WorkList
WorkList.define TKTown do

  redis :town,
        [
          {:self, [:name, :world, :founding_block, :founder]},
          {:members, :set},
          {:invited, :set},
          {:demos, :set},
          {:plot_categories, :hset},
          {:plots, :hset}
        ]


  job create(name, world, founder, fblock) do
    !self.name = name
    !self.world = world
    !self.founding_block = fblock
    !self.founder = founder

    !TKWorld.(world).towns =+ {name, @self}
    Minecraft.queue(:chat, [message: "broadcast-create-town", params: "dummy:#{name}", ttype: "world", target: world]) #PLAYER NAME

    TKTown.Join.perform_async([@self, founder])

    TKPlotCategory.Create.perform_async([UUID.uuid1(), "default", @self, 1000])
  end

  job join(player) do
    !self.members =+ player
    !TKPlayer.(player).town = @self
  end

  job leave(player) do
    !self.members =- player
    !TKPlayer.(player).town = nil

    if !self.founder == player do
      TKTown.Destroy.perform_async(@self)
    end
  end

  job destroy() do
    #TODO Convert this to this destroy
    #
    #UUIDUtil.fromString(R.get(uuid, "founding_block")).map(RemoteBlock::new)
    #                .ifPresent(RemoteBlock::destroy);
    #
    #UUIDUtil.fromString(R.get(uuid, "world")).map(RemoteWorld::new)
    #                .ifPresent(world -> world.removeTown(R.get(uuid, "name")));
    #
    #getPlots().forEach(Plot::dispose);
    #getPlotSettings().forEach(PlotSettings::dispose);
    #getDemographics().forEach(Demographic::dispose);
    #
    #

    TKBlock.Destroy.perform_async(!self.founding_block)

    world = !self.world #TODO this shouldn't be needed

    !TKWorld.(world).towns =- !self.name

    destroy(@self)
  end
end


