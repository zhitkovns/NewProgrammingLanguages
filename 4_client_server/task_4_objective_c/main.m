#include <stdio.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <string.h>

#define PORT 8084
#define BOARD_SIZE 5

int board[BOARD_SIZE][BOARD_SIZE] = {
    {1, 1, 0, 0, 0},
    {0, 0, 0, 1, 0},
    {0, 1, 0, 1, 0},
    {0, 1, 0, 0, 0},
    {0, 0, 0, 1, 1}
};
int ships_left = 8;

void run_server() {
    SOCKET server_fd, client_fd;
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    char buffer[1024] = {0};

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET) {
        fprintf(stderr, "socket failed\n");
        return;
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) == SOCKET_ERROR) {
        fprintf(stderr, "bind failed (port %d in use?)\n", PORT);
        return;
    }
    if (listen(server_fd, 3) == SOCKET_ERROR) {
        fprintf(stderr, "listen failed\n");
        return;
    }

    printf("Battleship server listening on port %d\n", PORT);
    fflush(stdout);

    if ((client_fd = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) == INVALID_SOCKET) {
        fprintf(stderr, "accept failed\n");
        return;
    }
    printf("Client connected\n");
    fflush(stdout);

    while (ships_left > 0) {
        memset(buffer, 0, sizeof(buffer));
        int valread = recv(client_fd, buffer, 1024, 0);
        if (valread <= 0) break;

        int row = buffer[0] - 'A';
        int col = buffer[1] - '1';
        char response[64];

        if (row >= 0 && row < BOARD_SIZE && col >= 0 && col < BOARD_SIZE) {
            if (board[row][col] == 1) {
                board[row][col] = 0;
                ships_left--;
                snprintf(response, sizeof(response), "HIT (ships left: %d)\n", ships_left);
            } else {
                snprintf(response, sizeof(response), "MISS\n");
            }
        } else {
            snprintf(response, sizeof(response), "INVALID\n");
        }

        printf("Shot at %c%c -> %s", buffer[0], buffer[1], response);
        fflush(stdout);
        send(client_fd, response, strlen(response), 0);
    }

    send(client_fd, "GAME OVER\n", 10, 0);
    closesocket(client_fd);
    closesocket(server_fd);
}

void run_client() {
    SOCKET sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[1024] = {0};
    char input[10];

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET) {
        fprintf(stderr, "Socket creation error\n");
        return;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);

    if (inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr) <= 0) {
        fprintf(stderr, "Invalid address\n");
        return;
    }

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == SOCKET_ERROR) {
        fprintf(stderr, "Connection failed. Is the server running?\n");
        return;
    }

    printf("Connected to server. Enter coordinates (e.g., A1, B4). Type Q to quit.\n");
    fflush(stdout);

    while (1) {
        printf("> ");
        fflush(stdout);
        if (scanf("%9s", input) != 1) break;

        if (input[0] == 'Q' || input[0] == 'q') break;

        send(sock, input, strlen(input), 0);
        memset(buffer, 0, sizeof(buffer));
        int valread = recv(sock, buffer, 1024, 0);
        if (valread <= 0) break;

        printf("%s", buffer);
        fflush(stdout);
        if (strstr(buffer, "GAME OVER")) break;
    }

    closesocket(sock);
}

int main(int argc, const char * argv[]) {
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        fprintf(stderr, "WSAStartup failed\n");
        return 1;
    }

    if (argc > 1 && strcmp(argv[1], "server") == 0) {
        run_server();
    } else {
        run_client();
    }

    WSACleanup();
    return 0;
}