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

    use Bitwise

    cXS = String.to_integer(xS) >>> 4; #Should i do bit shifting?
    cZS = String.to_integer(zS) >>> 4;

    cXE = String.to_integer(xE) >>> 4;
    cZE = String.to_integer(zE) >>> 4;

    town = !PlotCategory.(settings).town

    !Town.(town).plots =+ {name, @self}

    prio = !PlotCategory.(settings).priority

    Enum.each cXS..cXE, fn x -> Enum.each cZS..cZE, fn z ->
      Redis.rSend("zadd", "chunk:#{x}:#{z}:plots", prio, @self)
    end end
  end

  job destroy() do
    use Bitwise

    cXS = String.to_integer(!self.xS) >>> 4; #Should i do bit shifting?
    cZS = String.to_integer(!self.zS) >>> 4;

    cXE = String.to_integer(!self.xE) >>> 4;
    cZE = String.to_integer(!self.zE) >>> 4;

    Enum.each cXS..cXE, fn x -> Enum.each cZS..cZE, fn z ->
      Redis.rSend("zrem", "chunk:#{x}:#{z}:plots", @self)
    end end

    Minecraft.next_tick fn() -> redis_destroy(@self) end
  end
end
