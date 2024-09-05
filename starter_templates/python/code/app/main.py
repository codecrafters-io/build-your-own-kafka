import socket  # noqa: F401


def main():
    # You can use print statements as follows for debugging,
    # they'll be visible when running tests.
    print("Logs from your program will appear here!")

    # Uncomment this to pass the first stage
    #
    # server = socket.create_server(("localhost", 9092), reuse_port=True)
    # server.accept() # wait for client


if __name__ == "__main__":
    main()
