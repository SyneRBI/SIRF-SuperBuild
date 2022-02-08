import sys

this_python = sys.version_info[:2]
min_version = (3, 7)
if this_python < min_version:
    download_pip_file = "https://bootstrap.pypa.io/pip/{}.{}/get-pip.py.".format(*this_python)
else:
    download_pip_file = "https://bootstrap.pypa.io/get-pip.py"

print (download_pip_file)