#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#define PORT 8080
#define BACKLOG 16
#define BUFF_LEN 4 * 1024
#define HTTP_HDR "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n"

int main(void) {
    struct sockaddr_in addr = { .sin_family = AF_INET, .sin_port = htons(PORT), .sin_addr = {0} };

    printf("INFO: Creating socket...\n");
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (sock < 0) {
        printf("ERROR: Could not create socket\n");
        return 1;
    }
    printf("INFO: Socket created with file descriptor %d\n", sock);

    printf("INFO: Binding to port %d...\n", PORT);
    printf("sizeof(addr) = %zu\n", sizeof(addr));
    printf("sizeof(addr.sin_family) = %zu\n", sizeof(addr.sin_family));
    printf("sizeof(addr.sin_port) = %zu\n", sizeof(addr.sin_port));
    printf("sizeof(addr.sin_addr) = %zu\n", sizeof(addr.sin_addr));
    if (bind(sock, (const struct sockaddr*)&addr, sizeof(addr))< 0) {
        printf("ERROR: Could not bind socket\n");
        return 1;
    }
    printf("INFO: Socket bound to port %d (htons(%d) = %d)\n", PORT, PORT, htons(PORT));

    printf("INFO: Starting listening...\n");
    if (listen(sock, BACKLOG)< 0) {
        printf("ERROR: Could not start listening\n");
        return 1;
    };
    printf("INFO: Listening for connections\n");

    while (1) {
        struct sockaddr remote_addr = {0};
        unsigned int remote_addr_len = sizeof(remote_addr);

        printf("INFO: Awaiting connections...\n");
        int client_fd = accept(sock, &remote_addr, &remote_addr_len);

        // char read_buffer[BUFF_LEN] = {0};
        // int read_bytes = read(client_fd, read_buffer, BUFF_LEN-1);
        // printf("Received %d bytes:\n%s\n", read_bytes, read_buffer);

        const char *resp = HTTP_HDR"<html><h1>Hello world</h1></html>";
        send(client_fd, resp, strlen(resp), 0);
        close(client_fd);
    }

    return 0;
}

