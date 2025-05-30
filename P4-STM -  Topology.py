// File: topology/topology.py

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import RemoteController, OVSSwitch
from mininet.link import TCLink
from mininet.cli import CLI
from mininet.log import setLogLevel

class STMTopo(Topo):
    def build(self):
        h1 = self.addHost('h1', ip='10.0.1.1/24')
        h2 = self.addHost('h2', ip='10.0.2.2/24')

        s1 = self.addSwitch('s1')

        self.addLink(h1, s1, cls=TCLink, bw=10, delay='5ms')
        self.addLink(h2, s1, cls=TCLink, bw=10, delay='5ms')


def run():
    topo = STMTopo()
    net = Mininet(topo=topo, controller=None, switch=OVSSwitch, autoSetMacs=True)
    net.addController('c0', controller=RemoteController, ip='127.0.0.1', port=6653)

    net.start()
    print("\n--- Running Mininet CLI ---")
    CLI(net)
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    run()
