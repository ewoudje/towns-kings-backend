defmodule TownsKings.Repo.Minecraft do

  alias TownsKings.Repo.Macro.Redis
  alias __MODULE__

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

  def next_tick(execute) do
    GenServer.cast(TickExec, {:add, execute})
  end

end

defmodule TownsKings.Repo.Minecraft.TickExec do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: TickExec)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast({:add, exec}, state) do
    {:noreply, [exec | state]}
  end

  def handle_cast(:exec, state) do
    for exec <- state do
      exec.()
    end
    {:noreply, []}
  end
end

defmodule TownsKings.Repo.Minecraft.Tick do
  use FaktoryWorker.Job

  def perform() do
    GenServer.cast(TickExec, :exec)
    TownsKings.Repo.Macro.Redis.pipeline()
  end
end