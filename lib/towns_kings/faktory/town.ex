require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.Town do

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

    !World.(world).towns =+ {name, @self}
    Minecraft.queue(:chat, [message: "broadcast-create-town", params: "dummy:#{name}", ttype: "world", target: world]) #PLAYER NAME

    join(@self, founder)

    PlotCategory.create(UUID.uuid1(), "default", @self, 1000)
  end

  job join(player) do
    !self.members =+ player
    !Player.(player).town = @self
  end

  job leave(player) do
    !self.members =- player
    !Player.(player).town = nil

    if !self.founder == player do
      destroy(@self)
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

    Block.destroy(!self.founding_block)

    world = !self.world #TODO this shouldn't be needed

    !World.(world).towns =- !self.name

    redis_destroy(@self)
  end
end


