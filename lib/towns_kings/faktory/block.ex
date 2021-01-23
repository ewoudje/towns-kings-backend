require WorkList
WorkList.define TKBlock do

  redis :block,
        [
          {:self, [:world, :type, :x, :y, :z]}
        ]


  job create(world, type, x, y, z) do
    !self.world = world
    !self.type = type
    !self.x = x
    !self.y = y
    !self.z = z

    Redis.set("pos:#{x}:#{y}:#{z}", @self)
  end

  job destroy() do
    x = !self.x;
    y = !self.y;
    z = !self.z;

    world = !self.world;

    Redis.del("pos:#{x}:#{y}:#{z}")
    TK.queue(:block, [material: "air", x: x, y: y, z: z, world: world])
    destroy(@self)
  end
end
