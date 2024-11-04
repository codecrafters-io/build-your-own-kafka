#include <cstdlib>
#include <cstring>
#include <iostream>
#include <netdb.h>
#include <string>
#include <system_error>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>

int main(int argc, char* argv[]) {
    // Flush after every std::cout / std::cerr
    std::cout << std::unitbuf;
    std::cerr << std::unitbuf;

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    std::cerr << "Logs from your program will appear here!\n";

    // Create socket
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) {
        throw std::system_error(errno, std::generic_category(), "Failed to create server socket");
    }

    // Set socket options
    int reuse = 1;
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0) {
        close(server_fd);
        throw std::system_error(errno, std::generic_category(), "setsockopt failed");
    }

    // Configure server address
    struct sockaddr_in server_addr{};
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(9092);

    // Bind socket
    if (bind(server_fd, reinterpret_cast<struct sockaddr*>(&server_addr), sizeof(server_addr)) != 0) {
        close(server_fd);
        throw std::system_error(errno, std::generic_category(), "Failed to bind to port 9092");
    }

    // Listen for connections
    int connection_backlog = 5;
    if (listen(server_fd, connection_backlog) != 0) {
        close(server_fd);
        throw std::system_error(errno, std::generic_category(), "listen failed");
    }

    std::cout << "Waiting for a client to connect...\n";

    // Accept client connection
    struct sockaddr_in client_addr{};
    socklen_t client_addr_len = sizeof(client_addr);
    
    // Uncomment this block to pass the first stage
    // 
    // int client_fd = accept(server_fd, reinterpret_cast<struct sockaddr*>(&client_addr), &client_addr_len);
    // std::cout << "Client connected\n";
    // close(client_fd);

    close(server_fd);
    return 0;
}