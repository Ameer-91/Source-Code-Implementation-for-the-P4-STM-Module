// File: control/controller.py

import sys
import grpc
import os
from time import sleep
from p4runtime_lib.switch import ShutdownAllSwitchConnections
from p4runtime_lib.helper import P4InfoHelper

P4INFO_FILE_PATH = '../config/p4_stm.p4info.txt'
BINARY_FILE_PATH = '../config/p4_stm.json'


def write_register(p4info_helper, switch, reg_name, index, value):
    switch.WriteRegisterEntry(
        p4info_helper.buildRegisterEntry(
            register_name=reg_name,
            index=index,
            value=value
        )
    )


def read_register(p4info_helper, switch, reg_name, index):
    for response in switch.ReadRegisterEntries(p4info_helper.get_register_id(reg_name)):
        for entity in response.entities:
            entry = entity.register_entry
            if entry.index.index == index:
                print(f"Register {reg_name}[{index}] = {entry.data}")


def main():
    p4info_helper = P4InfoHelper(P4INFO_FILE_PATH)

    try:
        from p4runtime_lib.bmv2 import Bmv2SwitchConnection

        s1 = Bmv2SwitchConnection(
            name='s1',
            address='127.0.0.1:50051',
            device_id=0,
            proto_dump_file='logs/s1-p4runtime-requests.log'
        )

        s1.MasterArbitrationUpdate()
        s1.SetForwardingPipelineConfig(p4info=p4info_helper.p4info,
                                       bmv2_json_file_path=BINARY_FILE_PATH)

        print("\nInstalled P4 Program with P4Info and BMv2 JSON")

        # Optional: check register status for a sample index
        print("Reading initial register values at index 0:")
        read_register(p4info_helper, s1, "flow_byte_count", 0)
        read_register(p4info_helper, s1, "flow_pkt_count", 0)

    except KeyboardInterrupt:
        print(" Shutting down.")
    except grpc.RpcError as e:
        printGrpcError(e)
    finally:
        ShutdownAllSwitchConnections()


if __name__ == '__main__':
    main()
