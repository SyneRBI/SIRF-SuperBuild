import os
import shutil
import sys

def copy_if_not_exists(src, dst):
    from_file = os.path.abspath(src)
    to_file = os.path.abspath(dst)
    if not os.path.exists(to_file):
        shutil.copyfile(from_file, to_file)

if __name__ == '__main__':
    copy_if_not_exists(sys.argv[1], sys.argv[2])
