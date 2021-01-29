from __future__ import print_function, division
import sys

with open(sys.argv[1], 'r') as f:
    testdata = f.read()
    updated = testdata.replace('../NFFT.h', "NFFT.h")
    updated = updated.replace('../nfft_export.h', "nfft_export.h")
with open(sys.argv[2], 'w') as fw:    
    fw.write(updated)
