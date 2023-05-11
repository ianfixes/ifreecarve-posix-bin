#!/usr/bin/env python

import sys
import gzip
import xml.etree.ElementTree as ET
from contextlib import contextmanager


def usage():
    print("{} <input.opz> [output.opz] [section to move] [new parent]".format(sys.argv[0]))
    print(" - Move the specified diagram of an OpCat OPZ file to a new parent, and save as a new file")
    print("")
    print("Usage:")
    print("  {} input.opz".format(sys.argv[0]))
    print("    - List all OPM diagram names in input.opz")
    print("")
    print("  {} input.opz - foo bar".format(sys.argv[0]))
    print("    - Move diagram 'foo' in input.opz to a child of 'bar', print result XML to STDOUT")
    print("")
    print("  {} input.opz output.opz foo bar".format(sys.argv[0]))
    print("    - Move diagram 'foo' in input.opz to a child of 'bar', save result to output.opz")



@contextmanager
def opz_modifier(src_path, dest_path):
    with gzip.open(src_path, 'rb') as gz_file:
        tree = ET.parse(gz_file)
        root = tree.getroot()

    yield root

    resulting_xml = ET.tostring(root, encoding="utf-8").decode("utf-8")
    if dest_path is None:
        pass
    elif dest_path == "-":
        print(resulting_xml)
    else:
        with gzip.open(dest_path, 'wb') as file:
            file.write(resulting_xml.encode())


def move_node(root, child_node_name, new_parent_node_name):
    def parent(child_node):
        for node in root.iter():
            if child_node in node:
                return node
        return None
    # Find the child node and new parent node
    child_opd_node = root.find(".//OPD[@name='{}']".format(child_node_name))
    new_parent_opd_node = root.find(".//OPD[@name='{}']".format(new_parent_node_name))

    # Find the UnfoldingProperties tag of the child node
    immediate_parent = parent(child_opd_node)
    if "UnfoldingProperties" == immediate_parent.tag:
        parent(immediate_parent).remove(immediate_parent)
        new_parent_opd_node.find("Unfolded").append(immediate_parent)
    elif "InZoomed" == immediate_parent.tag:
        parent(child_opd_node).remove(child_opd_node)
        new_parent_opd_node.find("move_unfolded_node").append(child_opd_node)
    else:
        raise Exception("Don't know how to handle child of tag {}".format(immediate_parent.tag))

if len(sys.argv) < 2:
    usage()
    exit(1)

argv_dict = dict(enumerate(sys.argv))
with opz_modifier(argv_dict.get(1), argv_dict.get(2)) as xml_root:
    if argv_dict.get(3) and argv_dict.get(4):
        move_node(xml_root, sys.argv[3], sys.argv[4])
    else:
        print("\n".join([n.get('name') for n in xml_root.iter('OPD')]))
