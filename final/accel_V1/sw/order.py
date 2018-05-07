#!/usr/bin/python3
import sys
import json
import struct
import argparse
import collections

def main(argv):

    parser = argparse.ArgumentParser(description="Ordering the pages according to ranks")
    parser.add_argument("pr_binary", metavar="PR", help="a file holding the page rank result")
    parser.add_argument("-o", dest="output", default="output.json", help="output file name")

    arg_list = parser.parse_args(argv[1:])

    fi = open(arg_list.pr_binary, "rb")

    vec_len = int.from_bytes(fi.read(4), byteorder="little")
    print(vec_len)

    ranks = dict()

    cnt = 0

    while(True):
        b = fi.read(4)
        if not b:
            break
        rank = struct.unpack('f', b)
        ranks[cnt] = rank
        cnt = cnt + 1

    fi.close()

    indexes = sorted(range(vec_len), key=lambda i: ranks[i], reverse=True)

    jsondata = collections.OrderedDict()

    for i in range(vec_len):
        jsondata[indexes[i]] = ranks[indexes[i]]

    fo = open(arg_list.output, "w")
    json.dump(jsondata, fo, indent=2)
    fo.close()

if "__main__" == __name__:
    main(sys.argv)
