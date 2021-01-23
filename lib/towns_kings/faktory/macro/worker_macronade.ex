defmodule TownsKings.Repo.Macro.WorkerMacronade do
  @moduledoc false

  def start_process_inside([do: expr], params) do
    params = Enum.map params, fn p = {name, _, _} -> {name, p} end

    line1 = quote do
      Sentry.Context.add_breadcrumb(unquote([action: quote do __MODULE__ end, self: self__()] ++ params))
    end

    lines2 = case expr do
      {:__block__, _, i} -> Enum.map i, fn expr -> process_inside(expr) end
      i -> [process_inside(i)]
    end

    refr = fn
      {_, {:____ref, _, [key, uuid, module]}} -> quote do: Redis.get_(unquote(module).redis_fields_(), unquote(module).redis_name_(), unquote(key), unquote(uuid))
      {refr, {a, b, c}} when is_list c -> {a, b, Enum.map(c, fn i -> refr.({refr, i}) end)}
      {_, a} -> a
    end

    lines2 = Enum.map lines2, fn l -> refr.({refr, l}) end

    line3 = quote do
      Redis.pipeline()
    end

    [do: {:__block__, [], [line1] ++ lines2 ++ [line3]}]
  end

  def process_inside({:@, _, [{:self, _, _}]}) do
    self__()
  end

  def process_inside({:!, l, [{{:., _, [module, key]}, _, _}]}) do
    case module do
      {:self, _, _} -> {:____ref, l, [key, self__(), quote do: @parent_module]}
      {{:., _, [module]}, _, [uuid]} -> {:____ref, l, [key, uuid, module]}
    end
  end

  def process_inside({s, l, [left, right]}) do
    left = process_inside(left)
    right = process_inside(right)

    case {s, left, right} do
      {:=, {:____ref, _, [key, uuid, module]}, :nil} ->
        quote do
          send(self(), {:redis, Redis.rem_(unquote(module).redis_fields_(), unquote(key)),
            {unquote(uuid), unquote(module).redis_name_()}})
        end
      {:=, {:____ref, _, [key, uuid, module]}, {:+, _, [{right1, right2}]}} ->
        right1 = process_inside(right1)
        right2 = process_inside(right2)
        quote do
          send(self(), {:redis, Redis.add_(unquote(module).redis_fields_(), unquote(key), unquote(right1), unquote(right2)),
            {unquote(uuid), unquote(module).redis_name_()}})
        end
      {:=, {:____ref, _, [key, uuid, module]}, {:+, _, [right]}} ->
        quote do
          send(self(), {:redis, Redis.add_(unquote(module).redis_fields_(), unquote(key), unquote(right)),
            {unquote(uuid), unquote(module).redis_name_()}})
        end
      {:=, {:____ref, _, [key, uuid, module]}, {:-, _, [right]}} ->
        quote do
          send(self(), {:redis, Redis.rem_(unquote(module).redis_fields_(), unquote(key), unquote(right)),
            {unquote(uuid), unquote(module).redis_name_()}})
        end
      {:=, {:____ref, _, [key, uuid, module]}, _} ->
        quote do
          send(self(), {:redis, Redis.set_(unquote(module).redis_fields_(), unquote(key), unquote(right)),
            {unquote(uuid), unquote(module).redis_name_()}})
        end
      _ -> {s, l, [left, right]}
    end
  end

  def process_inside(skip = {a, b, params}) do
    if is_list(params) do
      {a, b, Enum.map(params, fn a -> process_inside(a) end)}
    else skip end
  end

  def process_inside([do: expr]) do
    [do: process_inside(expr)]
  end

  def process_inside(skip) do
    if is_list(skip) do
      Enum.map skip, fn a -> process_inside(a) end
    else
      skip
    end
  end


  #Dummy values so that the context is set to 'nil'
  def self__() do
    {:self__, [], nil}
  end

  def commands__() do
    {:commands__, [], nil}
  end

end
