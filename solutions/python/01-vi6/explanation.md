The entry point for your Kafka implementation is in `app/main.py`.

Study and uncomment the relevant code: 

```python
# Uncomment this to pass the first stage

server = socket.create_server(("localhost", 9092), reuse_port=True)
server.accept() # wait for client
```

Push your changes to pass the first stage:

```
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
