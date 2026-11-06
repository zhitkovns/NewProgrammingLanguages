#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <string.h>
#import <errno.h>

static int try_connect(int *out_sock) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        NSLog(@"socket error: %s", strerror(errno));
        return -1;
    }

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(8080);

    if (inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr) != 1) {
        NSLog(@"inet_pton failed");
        close(sock);
        return -1;
    }

    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        NSLog(@"connect error: %s", strerror(errno));
        close(sock);
        return -1;
    }

    *out_sock = sock;
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        int sock = -1;
        const int attempts = 3;

        for (int i = 0; i < attempts; i++) {
            NSLog(@"attempt %d of %d", i + 1, attempts);
            if (try_connect(&sock) == 0) {
                break;
            }
            sleep(1);
        }

        if (sock < 0) {
            NSLog(@"failed to connect after %d attempts", attempts);
            return 1;
        }

        NSLog(@"connected");

        const char *msg = "Hello from Objective-C client";
        ssize_t sent = send(sock, msg, strlen(msg), 0);
        if (sent < 0) {
            NSLog(@"send error: %s", strerror(errno));
            close(sock);
            return 1;
        }
        NSLog(@"sent %zd bytes", sent);

        char buffer[1024];
        ssize_t received = recv(sock, buffer, sizeof(buffer) - 1, 0);
        if (received < 0) {
            NSLog(@"recv error: %s", strerror(errno));
            close(sock);
            return 1;
        }
        if (received == 0) {
            NSLog(@"connection closed by peer");
            close(sock);
            return 1;
        }
        buffer[received] = '\0';
        NSLog(@"received: %s", buffer);

        close(sock);
    }
    return 0;
}