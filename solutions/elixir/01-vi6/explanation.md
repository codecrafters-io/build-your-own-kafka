The entry point for your Kafka implementation is in `lib/server.ex`.

Study and uncomment the relevant code: 

```elixir
# Uncomment this block to pass the first stage

# Since the tester restarts your program quite often, setting SO_REUSEADDR
# ensures that we don't run into 'Address already in use' errors
{:ok, socket} = :gen_tcp.listen(9092, [:binary, active: false, reuseaddr: true])
{:ok, _client} = :gen_tcp.accept(socket)
```

Push your changes to pass the first stage:

```
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
