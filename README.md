# 🚦 Intelligent Traffic Light Controller with Day/Night Mode & Pedestrian Support (8051)
A real-time, adaptive traffic light controller built on the 8051 microcontroller using assembly language. Simulates vehicle detection via buttons and supports pedestrian crossings with safety logic.

## Project Overview
This project implements a **smart traffic light controller** for a 4-way intersection using the **8051 microcontroller (AT89C51)**. It dynamically controls traffic flow based on **time of day** (Day/Night mode) and **simulated vehicle presence** using push buttons. Pedestrian safety is ensured with dedicated don't-walk/walk signals triggered only when perpendicular traffic is stopped.

This project demonstrates core embedded systems concepts: **interrupt-driven real-time clocks**, **state-machine logic**, **I/O interfacing**, and **modular assembly programming** — all without using Arduino or Raspberry Pi.

## Key Features
- **4-Phase Traffic Cycle**:  
  North-South → East-West → North-South → East-West (clockwise)
- **Dual Green Phases per Direction**:  
  Short **Right-Turn** phase → Extended **Straight-Green** phase
- **Day/Night Mode**:  
  - **Day Mode (6:00 AM – 10:00 PM)**: Full traffic + pedestrian cycle  
  - **Night Mode (10:00 PM – 5:59 AM)**: Flashing yellow for all directions
- **Simulated Vehicle Detection**:  
  Uses **push buttons (P3.0–P3.3)** to simulate IR sensors.  
  Green light extends if vehicle is detected during its phase.
- **Pedestrian Safety System**:  
  - Buttons on **P3.4 (N-S)** and **P3.5 (E-W)**  
  - Walk signals on **P3.6 (N-S)** and **P3.7 (E-W)**  
- **Real-Time Clock (Software)**:  
  Timer 0 interrupt (10ms) drives 1-second, 1-minute, and 1-hour counters.

## How to Run the Simulation
1.  Open **Proteus 8 Professional**.
2.  Load the circuit schematic (`schematic.png` for reference).
3.  Double-click the **AT89C51** component.
4.  Click **"..."** next to "Program File" and select `traffic.hex`.
5.  Click **OK**.
6.  Press the **Play** button to start simulation.
7.  Use **mouse clicks** on buttons to simulate:
    - Vehicle presence (P3.0–P3.3)
    - Pedestrian requests (P3.4–P3.5)
8. Observe traffic lights and pedestrian signals respond in real time.

## Notes
- **No Arduino/Raspberry Pi used** — fully implemented on 8051 assembly.
- The **Timer 0 ISR has known issues** with timekeeping in simulation — a focus for future research.
