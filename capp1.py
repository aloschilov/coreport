#!/usr/bin/python
"""
app1 loader
"""
import sys

if sys.platform == "win32":
    sys.path.extend(["libs", "libs/modules.dat"])


if __name__ == "__main__":
    if len(sys.argv) == 5 and sys.argv[1:4] == ["-c",
                                                "from multiprocessing.forking import main; main()",
                                                "--multiprocessing-fork"]:
        from multiprocessing.forking import main; main()
    else:
        import coreport.app1
        coreport.app1.main()

