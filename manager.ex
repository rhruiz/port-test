defmodule Manager do
  def start(worker \\ "elixir worker.exs") do
    Port.open({:spawn, worker}, [:binary, :use_stdio])
  end

  def send(port, term) do
    binary = term |> :erlang.term_to_binary() |> Base.encode64()

    Port.command(port, binary <> "\n")
    recv(port)
  end

  def recv(port) do
    receive do
      {^port, {:data, binary}} ->
        binary
        |> String.trim()
        |> Base.decode64!()
        |> :erlang.binary_to_term()

      other ->
        IO.inspect(other, label: "received")
    after
      5_000 ->
        raise "timeout"
    end
  end
end
