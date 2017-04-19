# Binary

Small library for handling binaries in Elixir. It's a wrapper around erlang :binary, plus a few String-alike functions.

When using it instead of erlang's :binary you get more sexy code and typespecs, plus you get some functions that String offers
like `reverse/1`, `trim_trailing/2` etc. You should not use String for binaries becaues it operates on codepoints, not bytes.

Full list of functions can be found on [hexdocs](https://hexdocs.pm/binary/Binary.html)

In edge cases, the behavior is modeled after Elixir.String. API will be frozen with version 0.1.0. I'm hoping to collect some
feedback first, but I don't plan any breaking API changes.

## Usage

Add dependency in your mix.exs:

```elixir
def deps do
  [{:binary, "~> 0.0.2"}]
end
```

Enjoy:
```elixir
iex> [1, 2] |> Binary.from_list |> Binary.pad_trailing(4) |> Binary.reverse |> Binary.split_at(-1)
{<<0, 0, 2>>,  <<1>>}
```

## License

MIT, check the [LICENSE](LICENSE) file. Just do whatever you like with this.

## Contributing

Even tiny contributios are very much welcome. Just open an issue or pull request on [github](https://github.com/comboy/elixir-binary).

