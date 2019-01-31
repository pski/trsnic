# trsnic

trsnic is a general purpose TCP/IP network interface for the TRS-80 line of microcomputers.  It is a fork of and therefore derived from and inspired by Arno Puder's amazing [RetroStoreCard](https://github.com/apuder/RetroStoreCard).  The product will initially support the TRS-80 Model III and 4 as this is the current support level of the RetroStoreCard source repository.  The long term goal is to support all TRS-80s, including the Models I/II/III/4/12/16/16B/6000.

See the [RetroStoreCard](https://github.com/apuder/RetroStoreCard) repository for details on how to build the hardware and configure the card.


trsnic provides the foundational protocols required to implement existing network interactions on the TRS-80 microcomputer.  The first such protocol provided is TCP/IP via an implementation of the Sockets API.  TCP/IP is the dominant low level network protocol in use today.  Many of today's higher level network protocols like HTTP and FTP are implemented on top of TCP/IP.  This means many modern networking systems can be built upon the base TCP/IP support provided by trsnic.

Additional protocols can be provided as demand requires. If desired, any protocol can be implemented by a contributer or forker of this repository.  While trsnic can be used standalone as a network  interface, a goal of the project is to synchronize changes upstream to the RetroStoreCard repository where they can be incorporated as part of the larger RetroStoreCard project.  

trsnic is currently implemented on the RetroStoreCard hardware architecture.  However, the API will endeavor to be hardware agnostic through the use of client-side adapters to allow support for other TRS-80 hardware networking alternatives, such as serial-IP converters, like the ATC-1000, the MISE/M3SE ethernet WIZnet module, legacy ARCNET controllers, Tandy's Network 4, etc.  In this way, software can be written using a single networking API that could potentially use different physical network interfaces, both modern and vintage OEM. Adapters can be developed for new interfaces that may be developed in the future with no application side changes required.


## TCP/IP Socket API

### A lightweight TCP/IP networking API

This API provides a subset of the standard TCP/IP Berkeley Sockets API with just enough functionality to create functioning TCP/IP client applications for the TRS-80. We attempt to adhere to the conventions of the Unix standard sockets library found in \<sys/types.h\> and \<sys/socket.h\>.  All API calls are sent to the Z80 I/O port 31 as a sequence of bytes where the socket function is represented by a single byte code.  Other parameters are defined as bytes per the specification below.  Responses for each function are read from the same port 31.

For an applicable and thorough course on socket programming, read the bible of TCP/IP Sockets programming [Unix Network Programming by W. Richard Stevens](https://www.amazon.com/Unix-Network-Programming-Sockets-Networking/dp/0131411551/ref=pd_lpo_sbs_14_t_0?_encoding=UTF8&psc=1&refRID=9ZM2JR92TQCZ6E4PDQ0J)

For a quicker tutorial on using sockets, see <https://www.tutorialspoint.com/unix_sockets/socket_core_functions.htm>

Only standard TCP streaming sockets are supported at this time.  TLS (secure sockets) and UDP (datagram) socket support will be in an upcoming release.

We have provided both [Z80 assembly and BASIC examples](https://github.com/pski/trsnic/tree/master/src/client/trsnic) of using the TCP/IP API.

### API Details

#### SOCKET (0x01)

Open a socket. 

**Unix:** *int socket (int family, int type, int protocol);*

Family: AF\_INET, AF\_INET6 *(AF\_INET6 not currently supported)*

Types: SOCK\_STREAM, SOCK\_DGRAM *(DGRAM not currently supported)*

Protocols: Defaults to TCP for SOCK\_STREAM and UDP for SOCK\_DGRAM *(UDP not currently supported)*

This call consists of 4 bytes sent in sequence to the trsnic i/o
port:

`<TCPIP><SOCKET><FAMILY><TYPE><VERSION>`

where

TCPIP = 0x14

SOCKET = 0x01

AF\_INET = 0x01 or AF\_INET6 = 0x02 *(AF\_INET6 not yet supported)*

SOCK\_STREAM = 0x01 or SOCK\_DGRAM = 0x02 *(SOCK\_DGRAM not yet supported)*

VERSION = 0x00 (*currently always 0. This allows future changes to the API. Applies to the socket lifetime.*)

**Example:** To open a TCP streaming socket, you would send 5 bytes to i/o port 31

`<0x14><0x01><0x01><0x01><0x00>`

**Response:** 2 bytes are returned. The first byte is status (1 for error, 0 for success). On success, the second byte returned is the socket file descriptor (sockfd).  This sockfd should be stored as it will be used by the other socket API functions below.  The second byte is set to the error number (errno) only when there is an error.

**Example:** Success returns <0x00><0x02> where byte 1 = success and byte 2 = sockfd (in this case the integer 2).  Failure returns <0x01><0x01> where byte 1 = error and byte 2 = errno (in this case 1)



#### CONNECT (0x02)

Connect to a server socket.  Only used for streaming sockets, ie. TCP SOCK_STREAM

**Unix**: *int connect(int sockfd, struct sockaddr \*serv_addr, int addrlen);*

There are 2 variations of CONNECT.  One accepts an **IP address** and one accepts a **hostname**.  Both accept a destination port.

##### CONNECT using an IP Address

CONNECT with IP address consists of 10 bytes (for an IPv4 address) to send to the trsnic i/o port.  Use 1 byte for the protocol, 1 byte for the CONNECT command, 1 byte for the sockfd, 1 byte for the host format (0x00 for IP address), 4 bytes for IPv4 addresses (or 6 bytes for IPv6 addresses, not currently supported) and a 2 byte port sent in network order.

`<TCPIP><CONNECT><SOCKFD><0x00><IP4><IP3><IP2><IP1><PORT MSB><PORT LSB>`

where 

TCPIP = 0x14

CONNECT = 0x02

SOCKFD = the socket descriptor returned from SOCKET

HOST FORMAT = 0x00 (0 indicates IP address)

IP4 = 0x00 to 0xFF

IP3 = 0x00 to 0xFF

IP2 = 0x00 to 0xFF

IP1 = 0x00 to 0xFF

PORT2 = 0x00 to 0xFF  MSB of 16bit port number 

PORT1 = 0x00 to 0xFF  LSB of 16bit port number 

**Example:** To connect to port 23 on a server listening on IP address 192.168.1.100

`<0x14><0x02><SOCKFD><0x00><0xC0><0xA8><0x01><0x64><0x00><0x17>`

##### CONNECT using a Hostname

CONNECT with a hostname consists of a series of bytes to send to the trsnic port.  Use 1 byte for the protocol, 1 byte for the CONNECT command, 1 byte for the sockfd, 1 byte for the host format(0x01 for hostname), the hostname in ASCII bytes followed by a NULL (0x00) (to indicate the end of the hostname) and ends with a 2 byte port sent in network order.

`<TCPIP><CONNECT><SOCKFD><0x01><HOSTNAME><NULL><PORT MSB><PORT LSB>`

where 

TCPIP = 0x14

CONNECT = 0x02

SOCKFD = the socket descriptor returned from SOCKET

HOST FORMAT = 0x01 (1 indicates null terminated hostname)

HOSTNAME = a sequence of ASCII bytes representing any valid hostname resolvable by your network DNS (e.g. www.google.com)

NULL = 0x00 (marks the end of the hostname string)

PORT2 = 0x00 to 0xFF  MSB of 16bit port number 

PORT1 = 0x00 to 0xFF  LSB of 16bit port number 

**Example:** To connect to port 23 on a server with hostname pski.net

`<0x14><0x02><SOCKFD><0x01><0x70><0x73><0x6B><0x69><0x2E><0x6E><0x65><0x74><0x00><0x00><0x17>`

**Response:** 1 or 2 bytes are returned. The first byte is 1 for error, 0 for success.  The second byte is set to errno only when there is an error.

**Example:** Success returns `<0x00>` where byte 1 = success.  Failure returns `<0x01><0x01>` where byte 1 = error and byte 2 = errno



#### SEND (0x03)

Sends data over the socket.

**Unix:** *int send(int sockfd, const void \*msg, int len, int flags);*

SEND consists of a 7 byte header and L bytes of data.

`<TCPIP><SEND><SOCKFD><L4><L3><L2><L1><DATA...>`

where

TCPIP = 0x14

SEND = 0x03

SOCKFD = the socket descriptor returned from SOCKET

L4-L1 = the length of the data specified as 4 bytes.  The *theoretical* maximum length of data in one send is 2,147,483,647 bytes.

DATA = a sequence of bytes of length len

**Example:** To send 260 bytes of data to a connected socket with sockfd = 1

`<0x14><0x03><0x01><0x00><0x00><0xFF><0x05><0xFF><0xFF>....<0xFF>` 
where byte 1 = TCPIP, byte 2 = SEND, byte 3 = SOCKFD, bytes 4 to 7 = data length of 260 and bytes 8 to (data length+8) are the data bytes.


**Response:** a 1 byte success flag (1 for error, 0 for success), followed by 4 byte response with the length of data actually sent on success or single byte errno on error.

**Example:** `<0x00><0x00><0x00><0xFF><0x05>` where byte 1 = success and bytes 2 to 5 = 32 bit data length of 260, or `<0x01><0x06>` where byte 1 = error and byte 2 = errno.


#### SENDTO (0x04) *(Not yet supported)*

Sends a UDP datagram over the socket.

**Unix:** *int send(int sockfd, const void \*msg, int len, int flags);*


#### RECV (0x05)

Receive data from the socket.  Use only for connection oriented sockets ie. TCP.

**Unix:** *int recv(int s, void \*buf, size_t len, int flags);*

`<TCPIP><RECV><SOCKFD><OPTION><L4><L3><L2><L1>`

where 

TCPIP = 0x14

RECV = 0x05

SOCKFD = the socket descriptor returned from SOCKET

OPTION (0 - blocking, 1 - nonblocking)

L4-L1 = the maximum length of the data to read specified as 4 bytes.  **Note:** The maximum length of data in one receive is currently 64K.

**Example:**
`<0x14><0x05><0x01><0x01><0x00><0x00><0xFF><0x05>` where byte 1 = TCPIP, 2 = RECV, 3 = SOCKFD, byte 4 = OPTION, bytes 5 to 8 = max data length to received with this request.

**Response:** a 1 byte success flag (1 for error, 0 for success), followed by 4 byte response with the 32 bit length of data followed by the data bytes.
On error only 2 bytes are returned. The first byte is 1 for error.  The second byte is set to errno when there is an error.

**Example:** `<0x00><L4><L3><L2><L1><DATA...>` or `<0x01><0x6>` where byte 1 = error and byte 2 = errno (in this case 6).


#### RECVFROM (0x06) *(Not yet supported)*

Receive a data gram from the socket.  Use only for connection-less sockets (ie. UDP);

**Unix:** *int recvfrom(int s, void buf\*, size\_t len\*, int flags\*, struct sockaddr from\*, socklen\_t fromlen\*);*

`<RECVFROM><SOCKFD><IP4><IP3><IP2><IP1><PORT MSB><PORT LSB>`

Returns a 1 byte success flag (1 for error, 0 for success), followed by 4 byte response with the length of data
On error only 2 bytes are returned. The first byte is 1 for error, 0 for success.  The second byte is set to errno when there is an error.

<0x00><L4><L3><L2><L1><DATA...>
or
<0x01><errno>


#### CLOSE (0x07)

Close a socket

**Unix:** *int close(int sockfd);*

Send 3 bytes to the trsnic port.

`<TCPIP><CLOSE><SOCKFD>`

TCPIP = 0x14

CLOSE = 0x07

SOCKFD = the socket descriptor returned from SOCKET

**Response:** 1 or 2 bytes are returned. The first byte is 1 for error, 0 for success.  The second byte is set to errno only when there is an error.

**Example:** `<0x00>` for succes or `<0x01><0x01>` for error.

-----
Have questions? [@pski](https://github.com)


