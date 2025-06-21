# verilog_traffic_light
A traffic light controller for a four-way intersection using Verilog HDL. The system includes timed transitions, pedestrian crossing signals, and a sensor-based traffic management system to handle varying traffic densities.

## Overview
Urban traffic congestion is a growing challenge in modern cities, demanding smarter and more adaptive traffic management solutions. This project presents a Verilog HDL-based traffic light controller, built using a finite state machine (FSM) for a four-way intersection.

## Objective
To efficiently regulate vehicle flow and ensure pedestrian safety using sensor-driven logic and timed signal transitions. The system dynamically adapts to varying traffic densities, minimizing delays and improving overall traffic movement.

## System Components
###Traffic Lights: Two signal sets manage North-South and East-West traffic, with standard red-yellow-green lights and pedestrian indicators.

###Vehicle Sensors: Monitor live traffic density across both directions.

###Pedestrian Signal Phase: Includes a dedicated "scramble crossing" mode where all vehicles are halted, allowing pedestrians to cross in any direction.

## Functionality
The FSM-based controller operates on a predefined timing sequence, enhanced by real-time sensor input. When high traffic is detected in one direction, the green phase is dynamically extended. A pedestrian crossing phase is triggered periodically, ensuring safe passage for all walkers while maintaining efficient traffic flow.
