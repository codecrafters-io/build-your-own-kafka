The entry point for your Kafka implementation is in `src/main.cpp`.

Study and uncomment the relevant code: 

```cpp
// Uncomment this block to pass the first stage

int client_fd = accept(server_fd, reinterpret_cast<struct sockaddr*>(&client_addr), &client_addr_len);
std::cout << "Client connected\n";
close(client_fd);
```

Push your changes to pass the first stage:

```
git add .
git commit -m "pass 1st stage" # any msg
git push origin master
```
