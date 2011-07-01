#!/usr/bin/python
"""
app1 loader
"""
import sys

if sys.platform == "win32":
    sys.path.extend(["libs", "libs/modules.dat"])

if __name__ == "__main__":
    import coreport.app1
    coreport.app1.main()

