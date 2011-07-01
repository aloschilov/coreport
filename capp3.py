#!/usr/bin/python
"""
app3 loader
"""
import sys

if sys.platform == "win32":
    sys.path.extend(["libs", "libs/modules.dat"])

if __name__ == "__main__":
    import coreport.app3
    coreport.app3.main()