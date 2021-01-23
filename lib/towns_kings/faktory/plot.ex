require TownsKings.Repo.Macro.WorkList
import TownsKings.Repo.Macro.WorkList

define_object TownsKings.Repo.Plot do

  redis :plot,
        [
          {:self, [:world, :depth, :name,
            :xS, :yS, :zS,
            :xE, :yE, :zE,
            :settings
          ]}
        ]


  job create(world, name, xS, yS, zS, xE, yE, zE, depth, settings) do
    !self.world = world
    !self.depth = depth
    !self.xS = xS
    !self.yS = yS
    !self.zS = zS
    !self.xE = xE
    !self.yE = yE
    !self.zE = zE
    !self.zE = zE
    !self.settings = settings


    cXS = xS / 16; #Should i do bit shifting?
    cZS = zS / 16;

    cXE = xE / 16;
    cZE = zE / 16;

    town = !PlotCategory.(settings).town

    !Town.(town).plots =+ {name, @self}

    prio = !PlotCategory.(settings).priority

    Enum.each cXS..cXE, fn x -> Enum.each cZS..cZE, fn z ->
      Redis.rSend("zadd", "chunk:#{x}:#{z}:plots", prio, @self)
    end end
  end

  job destroy() do
    cXS = !self.xS / 16; #Should i do bit shifting?
    cZS = !self.zS / 16;

    cXE = !self.xE / 16;
    cZE = !self.zE / 16;

    Enum.each cXS..cXE, fn x -> Enum.each cZS..cZE, fn z ->
      Redis.rSend("zrem", "chunk:#{x}:#{z}:plots", @self)
    end end
    redis_destroy(@self)
  end
end
