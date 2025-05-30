// File: p4_stm.p4

// This file implements the P4 program for the Stateful Traffic Monitoring (STM) module of the LBTMA framework

#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> ethType;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
}

struct headers {
    ethernet_t ethernet;
    ipv4_t     ipv4;
    tcp_t      tcp;
}

struct metadata {
    bit<1> alert;
    bit<32> flow_id;
    bit<16> pkt_len;
    bit<1> is_fragment;
    bit<8>  diffserv;
    bit<8>  protocol;
}

parser MyParser(packet_in pkt,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ethType) {
            0x0800: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        meta.diffserv = hdr.ipv4.diffserv;
        meta.protocol = hdr.ipv4.protocol;
        meta.pkt_len = hdr.ipv4.totalLen;
        meta.flow_id = hdr.ipv4.srcAddr ^ hdr.ipv4.dstAddr ^ hdr.ipv4.protocol;
        meta.is_fragment = hdr.ipv4.fragOffset != 0;
        transition select(hdr.ipv4.protocol) {
            6: parse_tcp;
            default: accept;
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        transition accept;
    }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    // Stateful traffic stats
    register<bit<32>>(1024) flow_byte_count;
    register<bit<32>>(1024) flow_pkt_count;

    apply {
        bit<32> index = meta.flow_id % 1024;
        bit<32> prev_bytes;
        bit<32> prev_pkts;

        flow_byte_count.read(prev_bytes, index);
        flow_pkt_count.read(prev_pkts, index);

        flow_byte_count.write(index, prev_bytes + meta.pkt_len);
        flow_pkt_count.write(index, prev_pkts + 1);

        if (meta.diffserv > 40 || meta.is_fragment == 1) {
            meta.alert = 1;
        } else {
            meta.alert = 0;
        }

        if (meta.alert == 1) {
            standard_metadata.egress_spec = 2; // critical channel
        } else {
            standard_metadata.egress_spec = 1; // routine channel
        }
    }
}

control MyEgress(...) {
    apply { }
}

control MyDeparser(packet_out pkt,
                   in headers hdr) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.tcp);
    }
}

V1Switch(MyParser(), MyIngress(), MyEgress(), MyDeparser()) main;
