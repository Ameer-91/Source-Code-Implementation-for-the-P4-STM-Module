
# P4-DPADS Traffic Generation Scenarios
# Tool: iperf and hping3
# Environment: Mininet-WiFi + P4 BMv2 Switches

# ========== Scenario 1: Varying Aggregation Thresholds and Intervals ==========
# Objective: Test adaptability to traffic patterns and aggregation parameters

# Start iperf server on h2
xterm h2 -e 'iperf -s -i 1' &

# Start TCP traffic from h1 to h2 (repeat with aggregation logic toggled)
xterm h1 -e 'iperf -c 10.0.0.2 -t 30 -i 1' &

# Optional hping3 to simulate sensor packet bursts
xterm h1 -e 'hping3 -S -p 12345 -i u10000 --count 1000 10.0.0.2' &

# ========== Scenario 2: Different Network Sizes ==========
# Objective: Evaluate scalability (50, 200, 500 devices)

# Use iperf with multiple parallel streams to simulate more devices
xterm h1 -e 'iperf -c 10.0.0.2 -P 5 -t 30 -i 1' &

# ========== Scenario 3: Dynamic Changes in Network Conditions ==========
# Objective: Test robustness with traffic spikes and bandwidth fluctuations

# Simulate a SYN flood (burst traffic)
xterm h1 -e 'hping3 -S --flood -p 80 10.0.0.2' &

# Simulate background UDP traffic
xterm h1 -e 'iperf -c 10.0.0.2 -u -b 5M -t 30' &

# ========== Scenario 4: IoT Nodes with Different Communication Rates ==========
# Objective: Assess behavior under low, medium, high rate IoT data

# Low-rate sensor simulation
xterm h1 -e 'hping3 -1 -i u500000 --count 10 10.0.0.2' &

# Medium-rate device
xterm h1 -e 'iperf -c 10.0.0.2 -t 30 -i 1' &

# High-rate camera feed
xterm h1 -e 'iperf -c 10.0.0.2 -P 10 -t 30' &

# ========== Scenario 5: Load Balancing Assessment ==========
# Objective: Evaluate even distribution of load across nodes

# Send concurrent streams to test aggregator/controller load balance
xterm h1 -e 'iperf -c 10.0.0.3 -t 30' &
xterm h1 -e 'iperf -c 10.0.0.4 -t 30' &
