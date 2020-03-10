from __future__ import print_function, division
import sys

with open(sys.argv[1], 'r') as f:
    testdata = f.read()
    updated = testdata.replace('sys.prefix', "os.environ['SIRF_INSTALL_PATH']")
with open(sys.argv[2], 'w') as fw:    
    fw.write(updated)
