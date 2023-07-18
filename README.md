# What is UART?

UART, or universal asynchronous receiver-transmitter, is one of the most
widely used device-to-device communication protocols. UART is a hardware
communication protocol that uses asynchronous serial communication with
configurable speed. Asynchronous means that there is no clock signal to
synchronise the transmitting device\'s output bits as they travel to the
receiving end.

When properly configured, UART can work with many different types of
serial protocols that involve transmitting and receiving serial data. In
serial communication, data is transferred bit by bit using a single line
or wire. In two-way communication, we use two wires for successful
serial data transfer. Depending on the application and system
requirements, serial communications need less circuitry and wires, which
reduces the cost of implementation.

In UART Communication, both Transmitter and Receiver agree on a common baud rate which signifies the amount of bits transferred per second.

Here, I have designed a transceiver which contains a Reciever and a Transmitter working on independant clocks. The design is kept parameterized to take the clock frequencies and baud rate as a parameter. I have also created a SystemVerilog based testbench for the design which tests the design for random data by connecting the transmitter and receiver to each other, keeping both at different clock frequencies to simulate actual communication.

# Transmitter Design

The transmitter is deigned to convert the parallel data to serial form
using a shift right register and transmit the data over to the receiver
maintaining a fixed baud rate. It uses a mealy machine for its working
which has 4 states, i.e., Idle, Load, Transmitting and Done state. It also consists
of a TxEnable input which is used as a trigger to begin transmission, a
reset input to reset the transmission line and bit counter to keep track
of the number of bits transferred. The bit counter maintains a max count
of 10 bits which refers to the 8 data bits along with the start bit (0)
and the stop bit (1).

# Receiver Design

The receiver also works on a similar mealy machine with 2 states, i.e.,
Idle and Receiving. It converts the serially received data to a parallel
format easy for the computer to process and store. Similar to the
Transmitter, this also has a baud counter and a bit counter to
synchronise the transmission.

# Testbench Design

The Testbench is created using SystemVerilog and tests the transciever by connecting the transmitter and receiver to each other and simulate actual communication using random data over a fixed baud rate.
