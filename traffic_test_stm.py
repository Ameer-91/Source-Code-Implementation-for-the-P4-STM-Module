#!/usr/bin/env python3

from mininet.net import Mininet
from mininet.cli import CLI
from mininet.node import RemoteController, OVSSwitch
from mininet.link import TCLink
from mininet.log import setLogLevel

def test_traffic():
    print("\nSetting up test topology...")
    net = Mininet(controller=RemoteController, switch=OVSSwitch, link=TCLink)
    
    h1 = net.addHost('h1', ip='10.0.1.1')
    h2 = net.addHost('h2', ip='10.0.2.2')
    s1 = net.addSwitch('s1')
    c0 = net.addController('c0', ip='127.0.0.1', port=6653)

    net.addLink(h1, s1, bw=10, delay='5ms')
    net.addLink(h2, s1, bw=10, delay='5ms')
    
    net.start()
    
    print("\nTesting connectivity...")
    net.pingAll()

    print("\nStarting iperf3 server on h2...")
    h2.cmd('iperf3 -s &')
    
    print("Running iperf3 client on h1...")
    h1.cmdPrint('iperf3 -c 10.0.2.2 -t 10')

    print("\nRunning hping3 SYN flood test (Ctrl+C to stop)...")
    print("NOTE: This is for testing alert flag path to port 2")
    h1.cmdPrint('hping3 -S 10.0.2.2 -p 80 --flood &')
    
    CLI(net)
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    test_traffic()
