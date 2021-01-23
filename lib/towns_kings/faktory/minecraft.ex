defmodule Minecraft do

  def queue(type, payload) do
    Minecraft.queue(type, payload, :fast)
  end

  def queue(type, payload, speed) do
    uuid = UUID.uuid1()

    Enum.each payload, fn {name, value} ->
      Redis.rSend("hset", "queue:#{uuid}", name, value)
    end


    Redis.rSend("hset", "queue:#{uuid}", "type", type)

    loc = case speed do
      :fast -> "mcqueue:fast"
      :med -> "mcqueue:med"
      :slow -> "mcqueue:slow"
    end

    Redis.rSend("rpush", loc, uuid)
  end

end