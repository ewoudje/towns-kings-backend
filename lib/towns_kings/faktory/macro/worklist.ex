defmodule WorkList do
  defmacro define(name, inside) do

    quote do
      import WorkList


      defmodule unquote(name) do
        unquote(inside)
      end

      unquote(case inside do
        [do: {:__block__, _, defines}] -> WorkList.Internal.define_workers(name, defines)
        _ -> nil
      end)
    end
  end

  defmacro redis(name, list) do
    quote do
      @redis_name unquote(name)
      @redis_fields []

      unquote(Enum.map list, fn(i) -> parse_redis(i) end)

      @redis_fields Map.new @redis_fields

      def redis_fields_ do
        @redis_fields
      end

      def redis_name_ do
        @redis_name
      end

      def destroy(uuid) do
        Enum.map @redis_fields, fn
          {_, {_, name}} -> Redis.del("#{@redis_name}:#{uuid}:#{name}")
          _ -> :ok
        end
      end
    end
  end

  def parse_redis({hset, :hset, data}) do
    quote do
      @redis_fields unquote(Macro.escape(Enum.map data, fn name -> {name, {:hset, Atom.to_string(hset), Atom.to_string(name)}} end)) ++ @redis_fields
      @redis_fields [unquote(Macro.escape({hset, {:hset, Atom.to_string hset}})) | @redis_fields]
    end
  end

  def parse_redis({:self, data}) do
    parse_redis({:self, :hset, data})
  end

  def parse_redis({name, :hset}) do
    quote do: @redis_fields [unquote(Macro.escape({name, {:hset, Atom.to_string name}})) | @redis_fields]
  end

  def parse_redis({name, :set}) do
     quote do: @redis_fields [unquote(Macro.escape({name, {:set, Atom.to_string name}})) | @redis_fields]
  end

  defmacro job({name, l, params}, _expr \\ nil) do
    quote do
      def unquote({name, l, params}) do
        (Module.concat [__MODULE__, unquote(WorkList.Internal.get_bname(name))]).perform_async(unquote(params))
      end
    end
  end

  defmodule Internal do
    def get_bname(name) do
      String.to_atom(Macro.camelize(Atom.to_string name))
    end

    def define_workers(mname, jobs) do
      {:__aliases__, _, [aname]} = mname
      Enum.map Enum.filter(jobs, fn {i, _, _} -> i == :job end), fn {:job, _, [{wname, l, params}, expr]} ->
        def = {:perform, l, [{:self__, l, nil} | params]}
        quote do
          defmodule unquote(Module.concat [aname, get_bname(wname)]) do
            import unquote(mname)
            use FaktoryWorker.Job

            @parent_module unquote(mname)

            def(unquote(def), unquote(WorkerMacronade.start_process_inside expr, params))
          end
        end
      end
    end
  end
end
