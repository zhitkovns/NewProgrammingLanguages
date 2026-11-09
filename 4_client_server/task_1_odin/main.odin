#+feature dynamic-literals

package main

import "core:fmt"
import "core:net"
import "core:strings"
import "core:os"

main :: proc() {
	local_addr, ok := net.parse_ip4_address("127.0.0.1")
	if !ok {
		fmt.eprintln("invalid ip address")
		os.exit(1)
	}

	port := 8081
	socket, listen_err := net.make_bound_udp_socket(local_addr, port)
	if listen_err != nil {
		fmt.eprintln("listen error:", listen_err)
		os.exit(1)
	}
	defer net.close(socket)

	fmt.printf("UDP name resolution server listening on 127.0.0.1:%d\n", port)

	dns_table := map[string]string{
		"google.com" = "142.250.74.46",
		"localhost"  = "127.0.0.1",
		"myhost"     = "192.168.1.100",
	}

	buffer: [1024]byte
	for i in 0 ..< 3 {
		bytes_read, client_endpoint, recv_err := net.recv_udp(socket, buffer[:])
		if recv_err != nil {
			fmt.eprintln("recv error:", recv_err)
			continue
		}

		req_str := strings.string_from_ptr(&buffer[0], bytes_read)
		req := strings.trim_space(req_str)
		fmt.printf("Received query: %q from %s\n", req, net.endpoint_to_string(client_endpoint))

		resp := "NOT_FOUND"
		if ip, found := dns_table[req]; found {
			resp = ip
		}

		_, send_err := net.send_udp(socket, transmute([]byte)resp, client_endpoint)
		if send_err != nil {
			fmt.eprintln("send error:", send_err)
		} else {
			fmt.printf("Sent response: %q\n", resp)
		}
	}
	fmt.println("Server stopped after 3 requests")
}