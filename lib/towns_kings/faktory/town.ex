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
    Minecraft.queue(:chat, [message: "create-town", params: "#{name}", ttype: "player", target: founder])
    Minecraft.queue(:chat, [message: "broadcast-create-town", params: "p@#{founder}:#{name}", ttype: "world", target: world])

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

    self = @self

    Minecraft.queue(:chat, [message: "player-left", params: "p@#{player}", ttype: "town", target: self])
    Minecraft.queue(:chat, [message: "leave-town", params: "t@#{self}", ttype: "player", target: player])

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

    for [_, plotC] <- Enum.chunk_every(!self.plot_categories, 2) do
      PlotCategory.destroy(plotC)
    end

    for [_, plot] <- Enum.chunk_every(!self.plots, 2) do
      Plot.destroy(plot)
    end


    !World.(world).towns =- !self.name

    Minecraft.next_tick fn() -> redis_destroy(@self) end
  end
end


