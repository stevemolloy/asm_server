#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define PORT 8080
#define BACKLOG 16

int main(void) {
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_port = htons(PORT),
        .sin_addr = {0},
    };

    printf("INFO: Creating socket...\n");
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        printf("ERROR: Could not create socket\n");
        return 1;
    } else {
        printf("INFO: Socket created with file descriptor %d\n", sock);
    }

    printf("INFO: Binding to port %d...\n", PORT);
    int retval = bind(sock, (const struct sockaddr*)&addr, sizeof(addr));
    if (retval < 0) {
        printf("ERROR: Could not bind socket\n");
        return 1;
    } else {
        printf("INFO: Socket bound to port %d (htons(%d) = %d)\n", PORT, PORT, htons(PORT));
    }

    printf("INFO: Starting listening...\n");
    retval = listen(sock, BACKLOG);
    if (retval < 0) {
        printf("ERROR: Could not start listening\n");
        return 1;
    } else {
        printf("INFO: Listening for connections\n");
    }

    printf("INFO: Awaiting connections...\n");
    struct sockaddr remote_addr = {0};
    unsigned int remote_addr_len = sizeof(remote_addr);
    retval = accept(sock, &remote_addr, &remote_addr_len);

    return 0;
}

