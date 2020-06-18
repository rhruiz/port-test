defmodule Worker do
  def read do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts(:stderr, "Boom because: #{inspect(reason)}")
        File.write("error.txt", inspect(reason))

      data ->
        content =
          data
          |> (fn x ->
                IO.inspect(:stderr, x, [])
                x
              end).()
          |> String.trim()
          |> Base.decode64!()
          |> :erlang.binary_to_term()
          |> (fn x ->
                File.write("command.txt", inspect(x))
                x
              end).()
          |> handle()
          |> :erlang.term_to_binary()
          |> Base.encode64()

        IO.puts(content)
        read()
    end
  end

  def handle({:apply, m, f, a}) do
    apply(m, f, a)
  end
end

Worker.read()
