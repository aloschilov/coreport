#!/usr/bin/python
"""
app2 loader
"""
import sys

if sys.platform == "win32":
    sys.path.extend(["libs","libs/modules.dat"])

if __name__ == "__main__":
    import coreport.app2
    coreport.app2.main()