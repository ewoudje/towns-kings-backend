defmodule Redis do
  alias __MODULE__
  @moduledoc false

  def pipeline() do
    commands = recv_commands([])

    Redix.pipeline!(:redix, commands)
  end

  defp recv_commands(list) do
    receive do
      #{:redis, {s, n, v}} -> recv_commands([[s | ["#{type}:#{uuid}:#{n}" | v]] | list])
      #{:redis, {s, n, v}, {u}} -> recv_commands([[s | ["#{type}:#{u}:#{n}" | v]] | list])
      {:redis, {s, n, v}, {u, t}} -> recv_commands([[s | ["#{t}:#{u}:#{n}" | v]] | list])
      {:redis, {:command, l}} -> recv_commands([l | list])
    after
      0 -> list
    end
  end

  def set_(fields, key, value) do
    case Map.fetch(fields, key) do
      { :ok, {:hset, loc, field}} -> {"hset", loc, [field, value]}
      _ -> raise "#{key} doesn't exist! or Is wrong type!"
    end
  end

  def add_(fields, key, value) do
    case Map.fetch(fields, key) do
      { :ok, {:set, loc}} -> {"sadd", loc, [value]}
      _ -> raise "#{key} doesn't exist! or Is wrong type!"
    end
  end

  def add_(fields, fkey, key, value) do
    case Map.fetch(fields, fkey) do
      { :ok, {:hset, loc}} -> {"hset", loc, [key, value]}
      _ -> raise "#{fkey} doesn't exist! or Is wrong type!"
    end
  end

  def rem_(fields, key) do
    case Map.fetch(fields, key) do
      { :ok, {:hset, loc, field}} -> {"hdel", loc, [field]}
      { :ok, {:hset, loc}} -> {"del", loc}
      { :ok, {:set, loc}} -> {"del", loc}
      _ -> raise "#{key} doesn't exist! or Is wrong type!"
    end
  end

  def rem_(fields, key, value) do
    case Map.fetch(fields, key) do
      { :ok, {:set, loc}} -> {"srem", loc, [value]}
      { :ok, {:hset, loc}} -> {"hdel", loc, [value]}
      _ -> raise "#{key} doesn't exist! or Is wrong type!"
    end
  end

  def get_(fields, name, key, uuid) do
    {:ok, r} = Redix.command(:redix, case Map.fetch(fields, key) do
      { :ok, {:hset, loc, field}} -> ["hget", "#{name}:#{uuid}:#{loc}", field]
      { :ok, {:hset, loc}} -> ["hgetall", "#{name}:#{uuid}:#{loc}"]
      { :ok, {:set, loc}} -> ["smembers", "#{name}:#{uuid}:#{loc}"]
      _ -> raise "#{key} doesn't exist! or Is wrong type!"
    end)

    r
  end

  def rSend(command, loc) do
    send(self(), {:redis, {:command, [command, loc]}})
  end

  def rSend(command, loc, value) do
    send(self(), {:redis, {:command, [command, loc, value]}})
  end

  def rSend(command, loc, value, value2) do
    send(self(), {:redis, {:command, [command, loc, value, value2]}})
  end

  def set(loc, value) do
    rSend("set", loc, value)
  end

  def del(loc) do
    rSend("del", loc)
  end
end
