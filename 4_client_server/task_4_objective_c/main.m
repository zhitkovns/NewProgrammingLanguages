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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ret = 0;
    int sock = -1;
    int i;
    ssize_t sent;
    ssize_t received;
    const int attempts = 3;
    const char *msg = "Hello from Objective-C client";
    char buffer[1024];

    for (i = 0; i < attempts; i++) {
        NSLog(@"attempt %d of %d", i + 1, attempts);
        if (try_connect(&sock) == 0) {
            break;
        }
        sleep(1);
    }

    if (sock < 0) {
        NSLog(@"failed to connect after %d attempts", attempts);
        ret = 1;
        goto cleanup;
    }

    NSLog(@"connected");

    sent = send(sock, msg, strlen(msg), 0);
    if (sent < 0) {
        NSLog(@"send error: %s", strerror(errno));
        ret = 1;
        goto cleanup;
    }
    NSLog(@"sent %zd bytes", sent);

    received = recv(sock, buffer, sizeof(buffer) - 1, 0);
    if (received < 0) {
        NSLog(@"recv error: %s", strerror(errno));
        ret = 1;
        goto cleanup;
    }
    if (received == 0) {
        NSLog(@"connection closed by peer");
        ret = 1;
        goto cleanup;
    }
    buffer[received] = '\0';
    NSLog(@"received: %s", buffer);

cleanup:
    if (sock >= 0) close(sock);
    [pool drain];
    return ret;
}