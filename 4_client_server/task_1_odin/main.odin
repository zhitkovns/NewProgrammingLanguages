package main

import "core:fmt"
import "core:net"
import "core:os"

main :: proc() {
	endpoint := net.Endpoint{
		address = net.IP4_Address{127, 0, 0, 1},
		port    = 8080,
	}

	listener, listen_err := net.listen_tcp(endpoint)
	if listen_err != nil {
		fmt.eprintln("listen error:", listen_err)
		os.exit(1)
	}
	defer net.close(listener)

	fmt.println("server listening on 127.0.0.1:8080")

	for i in 0 ..< 3 {
		client, _, accept_err := net.accept_tcp(listener)
		if accept_err != nil {
			fmt.eprintln("accept error:", accept_err)
			continue
		}

		fmt.printfln("client %d connected", i + 1)

		buffer: [4096]u8
		for {
			n, recv_err := net.recv_tcp(client, buffer[:])
			if recv_err != nil {
				fmt.eprintln("recv error:", recv_err)
				break
			}
			if n == 0 {
				break
			}
			fmt.printfln("received %d bytes", n)

			_, send_err := net.send_tcp(client, buffer[:n])
			if send_err != nil {
				fmt.eprintln("send error:", send_err)
				break
			}
		}
		net.close(client)
	}

	fmt.println("server stopped")
}