# Usage:
#   python3 ./bcov2bedgraph.py test/example.bcov > test/example.bedgraph
import sys
import os


def bcov(src, start=0):
    with open(src, 'rb') as f:
        f.seek(start * 2)
        while True:
            value = f.read(2)
            if not value:
                break
            yield value[0] * 256 + value[1]


prev_value, prev_pos, index = (None, None, -1)
chr = os.path.basename(sys.argv[1]).replace('.bcov', '')
if os.path.isfile(sys.argv[1]):
    for value in bcov(sys.argv[1]):
        index += 1
        if value != prev_value:
            if prev_value != None:
                print(f"{chr}\t{prev_pos}\t{index}\t{prev_value}")
            prev_value = value
            prev_pos = index

if index > 0:
    print(f"{chr}\t{prev_pos}\t{index+1}\t{value}")
