# UART Transmitter and Receiver

A simple UART (Universal Asynchronous Receiver/Transmitter) module written in Verilog, built and simulated in Xilinx Vivado. This project implements both the transmitter and receiver logic in a single module, along with a testbench that loops the transmitter output back into the receiver to verify correct operation.

## Overview

UART is one of the most common serial communication protocols used to send data between digital devices one bit at a time. This project implements:

- **Transmitter (TX):** Converts an 8-bit parallel data input into a serial bitstream, framed with a start bit and a stop bit, and sends it out at a configurable baud rate.
- **Receiver (RX):** Samples an incoming serial bitstream, detects the start bit, captures the 8 data bits at the correct timing, and reconstructs the original byte.

Both blocks are driven by the same baud rate generator, which divides the system clock down to match the desired baud rate (default: 9600 baud).

## Files

| File | Description |
|------|-------------|
| `rx_tx.v` | Main UART module containing both the transmitter and receiver FSMs |
| `tb.v` | Testbench that connects TX output directly to RX input (loopback) and sends a sequence of test bytes |

## How It Works

- The **transmitter** is a 4-state FSM (`idle → start → data → stop`) that shifts out one bit of `data_in` per baud tick.
- The **receiver** is a 3-state FSM (`idle → wait → recv`) that waits for the start bit, aligns itself to the middle of each bit period, and shifts incoming bits into a register.
- `rx_done` pulses high once a full byte has been received, and `rx_out` holds the received byte.

## Simulation

The testbench (`tb.v`) generates a clock, applies reset, and transmits a series of test bytes (`35`, `44`, `15`, `14`) back into the receiver through a loopback connection (`tx` tied to `rx`). Each transmission is followed by a wait on `rx_done` before sending the next byte.

To run it in Vivado:
1. Add `rx_tx.v` and `tb.v` as simulation sources.
2. Set `tb` as the top module for simulation.
3. Run Behavioral Simulation.

## Waveform

Below is the simulation waveform showing `clk`, `rst`, `tx_start`, `data_in`, `txrx`, `tx_busy`, `rx_out`, and `rx_done`:

## UART Waveform
<img width="1920" height="1080" alt="Screenshot 2026-09-19 002716" src="https://github.com/user-attachments/assets/32512a3d-914f-4a3c-8b0a-8ff49baf3c51" />
## UART schematic
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/4753c651-2558-44a0-b8a0-43fea8f7ffa0" />



## Status

This project is a work in progress — currently debugging timing issues between the transmitter and receiver to ensure `rx_out` correctly matches `data_in` on every cycle.
