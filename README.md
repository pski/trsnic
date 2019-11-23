# trsnic

**trsnic** is a general purpose WiFi [TCP/IP](https://en.wikipedia.org/wiki/Internet_protocol_suite) network interface for the TRS-80 line of microcomputers.  It is a fork of Arno Puder's amazing [TRS-IO](https://github.com/apuder/TRS-IO).  The product will initially support the TRS-80 Model III and 4 as this is the current support level of the TRS-IO source repository.  The long term goal is to support all TRS-80s, including the Models I/II/III/4/12/16/16B/6000.

**trsnic** provides the foundational protocols required to implement existing network interactions on the TRS-80 microcomputer.  The first such protocol provided is TCP/IP via an implementation of the [Berekely Sockets API](https://en.wikipedia.org/wiki/Berkeley_sockets).  TCP/IP is the dominant low level network protocol in use today.  Many of today's higher level network protocols like HTTP and FTP are implemented on top of TCP/IP.  This means many modern networking systems can be built upon the base TCP/IP support provided by **trsnic**.

Additional protocols can be provided as demand requires. If desired, any protocol can be implemented by a contributer or forker of this repository.  

**trsnic** is currently implemented on the TRS-IO architecture.  However, the API will endeavor to be hardware agnostic through the use of client-side adapters to allow support for other TRS-80 hardware networking alternatives, such as serial-IP converters, like the ATC-1000, the MISE/M3SE ethernet WIZnet module, legacy ARCNET controllers, Tandy's Network 4, etc.  In this way, software can be written using a single networking API that could potentially use different physical network interfaces, both modern and vintage OEM. Adapters can be developed for new interfaces that may be developed in the future with no application side changes required.

#### TRS-IO Card
![TRS-IO](./doc/trs-io-card-v1.png)

**Note** If you have the previous generation RestroStoreCard or **trsnic** card then you need to [make some modifications to the circuit wiring](./doc/rs_fix.md) in order to work with TRS-IO architecture.

## Building the Hardware

1. Make the [circuit board](./kicad/v1).
2. Get the [parts](./doc/build.md).
3. Program the [GAL](./gal).
4. Install the [ESP-IDF v3.2.2](https://github.com/espressif/esp-idf/tree/v3.2.2).
5. Run `make` in the project root.
6. Run `make menuconfig`in the [/src/esp directory](./src/esp).
7. Run `make flash monitor`.
8. Follow the setup directions on the [TRS-IO](https://github.com/apuder/TRS-IO) site.


## Programming

See [TCP/IP API](./doc/tcp_ip.md) 

-----
Have questions? [@pski](https://github.com)


