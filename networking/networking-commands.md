# Networking Homework – Task 2

## Introduction

This document contains the networking commands I practiced on Linux. I executed each command in the terminal, recorded the output, and added a short explanation of what I understood from each command.

Screenshots of the commands and their outputs are available in the `screenshots/` folder.

---

## 1. hostname

### Command

```bash
hostname
```

### Output

```text
IdeaPad
```

### Explanation

The `hostname` command displays the name of the computer on the network.  
In my system, the hostname is `IdeaPad`.

---

## 2. ip addr

### Command

```bash
ip addr
```

### Output

```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever

2: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether b8:1e:a4:d7:47:4b brd ff:ff:ff:ff:ff:ff
    inet 10.114.6.210/21 brd 10.114.7.255 scope global dynamic noprefixroute wlp2s0
       valid_lft 77526sec preferred_lft 77526sec
    inet6 fe80::645f:90c3:1cc6:2d19/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 62:61:b0:ad:98:1a brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
```

### Explanation

The `ip addr` command displays network interfaces and their IP addresses.

- `lo` is the loopback interface.
- `wlp2s0` is the wireless network interface.
- `10.114.6.210/21` is the IPv4 address assigned to the wireless interface.
- `docker0` is a virtual network interface created by Docker.

---

## 3. ip route

### Command

```bash
ip route
```

### Output

```text
default via 10.114.0.1 dev wlp2s0 proto dhcp src 10.114.6.210 metric 600
10.114.0.0/21 dev wlp2s0 proto kernel scope link src 10.114.6.210 metric 600
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
```

### Explanation

The `ip route` command displays the routing table of the system.

The default route shows that network traffic is sent through the gateway `10.114.0.1` using the wireless interface `wlp2s0`.

---

## 4. ping

### Command

```bash
ping -c 4 google.com
```

### Output

```text
PING google.com (142.250.207.238) 56(84) bytes of data.
64 bytes from del12s11-in-f14.1e100.net (142.250.207.238): icmp_seq=1 ttl=117 time=101 ms
64 bytes from del12s11-in-f14.1e100.net (142.250.207.238): icmp_seq=2 ttl=117 time=175 ms
64 bytes from del12s11-in-f14.1e100.net (142.250.207.238): icmp_seq=3 ttl=117 time=44.3 ms
64 bytes from del12s11-in-f14.1e100.net (142.250.207.238): icmp_seq=4 ttl=117 time=29.7 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 29.719/87.625/175.414/57.272 ms
```

### Explanation

The `ping` command checks whether a destination is reachable over the network.

The `-c 4` option sends four packets. In my test, all four packets were received and there was `0% packet loss`, which shows that the connection to `google.com` was successful.

---

## 5. ss -tuln

### Command

```bash
ss -tuln
```

### Output

```text
Netid State  Recv-Q Send-Q  Local Address:Port    Peer Address:Port Process
udp   UNCONN 0      0             0.0.0.0:34965        0.0.0.0:*
udp   UNCONN 0      0         224.0.0.251:5353         0.0.0.0:*
udp   UNCONN 0      0         224.0.0.251:5353         0.0.0.0:*
udp   UNCONN 0      0         224.0.0.251:5353         0.0.0.0:*
udp   UNCONN 0      0         224.0.0.251:5353         0.0.0.0:*
udp   UNCONN 0      0             0.0.0.0:5353         0.0.0.0:*
udp   UNCONN 0      0          127.0.0.54:53           0.0.0.0:*
udp   UNCONN 0      0       127.0.0.53%lo:53           0.0.0.0:*
udp   UNCONN 0      0                [::]:37548           [::]:*
udp   UNCONN 0      0                [::]:5353            [::]:*
tcp   LISTEN 0      4096    127.0.0.53%lo:53           0.0.0.0:*
tcp   LISTEN 0      4096        127.0.0.1:42587        0.0.0.0:*
tcp   LISTEN 0      4096        127.0.0.1:631          0.0.0.0:*
tcp   LISTEN 0      4096        127.0.0.1:8991         0.0.0.0:*
tcp   LISTEN 0      70          127.0.0.1:33060        0.0.0.0:*
tcp   LISTEN 0      151         127.0.0.1:3306         0.0.0.0:*
tcp   LISTEN 0      4096       127.0.0.54:53           0.0.0.0:*
tcp   LISTEN 0      4096            [::1]:631             [::]:*
```

### Explanation

The `ss` command displays information about network sockets.

The options used are:

- `-t` displays TCP sockets.
- `-u` displays UDP sockets.
- `-l` displays listening sockets.
- `-n` displays numerical addresses and port numbers.

This command helps identify active and listening network ports on the system.

---

## 6. nslookup

### Command

```bash
nslookup google.com
```

### Output

```text
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.207.238
Name:   google.com
Address: 2404:6800:4009:826::200e
```

### Explanation

The `nslookup` command is used to query DNS information.

It converts a domain name such as `google.com` into IP addresses. In my output, both an IPv4 address and an IPv6 address were returned.

---

## Conclusion

Through these commands, I practiced basic Linux networking concepts including:

- Finding the hostname of a system.
- Viewing network interfaces and IP addresses.
- Checking the routing table.
- Testing network connectivity.
- Viewing active network sockets and listening ports.
- Performing DNS lookups.

The screenshots of the commands and outputs are stored in the `screenshots/` directory.
