
# 📡 P4-STM: Stateful Traffic Monitoring with P4

The **P4-STM** module is part of the LBTMA framework for SDN-enabled IoT networks, providing advanced traffic monitoring capabilities using P4-programmable switches.

---

## 🔍 Overview

P4-STM utilizes programmable state tables to capture and analyze key traffic features—such as source/destination IPs, packet sizes, and protocols—at the data plane level. It integrates anonymization for privacy and uses a novel Multi-Controller Communication Scheme (MCCS) to separate routine monitoring data from critical alerts.

---

## 📦 Features

- **Protocol Support**: Ethernet, IPv4, TCP
- **Flow Identification**: Based on IP & transport headers
- **Metrics Tracked**:
  - `flow_byte_count`
  - `flow_pkt_count`
- **Security**: Real-time anonymization of identifiers
- **Channel Separation (MCCS)**:
  - Port 1 → DCRD (routine)
  - Port 2 → PCHPA (critical alerts)

---

## 🗂 Structure

```
P4-STM/
├── p4src/p4_stm.p4
├── build/p4_stm.json
├── build/p4_stm.p4info.txt
├── control/controller.py
├── topology/topology.py
├── scripts/run_mininet.sh
├── scripts/traffic_test_stm.py
└── README.md
```

---

## 🚀 Run Instructions

1. Compile and run setup:

```bash
chmod +x scripts/run_mininet.sh
./scripts/run_mininet.sh
```

2. Test traffic:

```bash
sudo python3 scripts/traffic_test_stm.py
```

---

## ⚙️ Dependencies

- Python 3.6+
- Mininet, iperf3, hping3
- gRPC, protobuf
- P4 toolchain (`p4c`, `bmv2`)

---

## 📈 Example Traffic

- Routine: `iperf3 -s` on `h1`, `iperf3 -c` from `h2`
- Alert-trigger: `hping3 -S 10.0.1.1 -p 80 --flood`

---

## 🛡 Anonymization

All monitored flows are anonymized at ingress using hashing/scrambling of IP/device identifiers. This prevents tracking and complies with privacy regulations.

---

## 🧠 Integration with LBTMA

P4-STM feeds anonymized flow features into:

- **P4-DLBS**: Load-aware routing
- **P4-DPADS**: Aggregation & disaggregation
- **MCCS**: Smart control-plane coordination

---

## 📘 References

- [P4.org](https://p4.org)
- [BMv2 repo](https://github.com/p4lang/behavioral-model)
- [ONOS Controller](https://onosproject.org)

---

This project is part of the LBTMA framework for SD-IoT networks.

---
