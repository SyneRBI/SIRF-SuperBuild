import sys
import re
import subprocess
import functools

def conda_install(package):
    return f'mamba install -y -c conda-forge {package}'.rstrip()

def pip_install(package):
    return f'pip install -U {package}'.rstrip()

not_on_conda_forge = ['brainweb']

if __name__ == '__main__':
    infile = sys.argv[1]

    install_by_conda = []
    install_by_pip = []
    with open(infile , 'r') as f:
        for line in f:
            if line[0].strip() not in ['#', '']:
                # clean line after any comment
                if '#' in line:
                    line = line.split('#')[0]
                for pkg in not_on_conda_forge:
                    pattern = re.compile(f'{pkg}(.*)')
                    mtc = pattern.match(line.rstrip())
                    if mtc is None:
                        install_by_conda.append(line.rstrip())
                    else:
                        print (f'Not on conda-forge: {line.rstrip()}')
                        install_by_pip.append(line.rstrip())
    
    install_by_conda = functools.reduce(lambda x, y: x + ' ' + y, install_by_conda, '')
    

    install_by_pip = functools.reduce(lambda x, y: x + ' ' + y, install_by_pip, '')
    

    try:
        print ("Installing from conda-forge:", install_by_conda)
        subprocess.run(conda_install(install_by_conda), shell=True, check=True)
        print ("Installing from PyPI:", install_by_pip)
        subprocess.run(pip_install(install_by_pip), shell=True, check=True)
        
    except subprocess.CalledProcessError as cpe:
        print (cpe)