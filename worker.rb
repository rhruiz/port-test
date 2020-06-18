require 'bundler/setup'
require 'base64'

Bundler.require

$stdout.sync = true

def decode(input)
  Erlang.binary_to_term(Base64.decode64(input))
end

def encode(output)
  Base64.encode64(Erlang.term_to_binary(output))
end

def handle(input)
  if input.kind_of?(Erlang::Tuple)
    case input[0]
    when Erlang::Atom[:apply]
      klass, meth, args = input[1..3]

      Erlang::Binary[Object.const_get(klass.to_s.sub("Elixir.", "")).send(meth, *args).inspect]
    end
  end
end

$stdin.each_line do |line|
  puts encode(handle(decode(line)))
end

