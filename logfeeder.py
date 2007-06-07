#!/usr/bin/env python
#
# logfeeder.py
#
# reads a specified file and outputs it in delayed chunks
#

import sys
import random
import time

if sys.argv < 1: 
  print 'Usage logfeeder.py <input>'

lines = file(sys.argv[1]).readlines()
for line in lines:
  print line.strip()
  sys.stdout.flush()
  time.sleep(random.random() * 5)

