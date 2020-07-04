#!/bin/bash

JUPPWD=$1
JUPPORT=$2
DSTUSER=$3

echo User = $DSTUSER

cd /tmp
sed -i -- "s/%%TARGETUSER%%/${DSTUSER}/g" jupyter.service
sudo mv jupyter.service /etc/systemd/system/jupyter.service
sudo chmod 755 /etc/systemd/system/jupyter.service

sudo mkdir -p /srv/jupyter
sed -i -- "s/%%TARGETUSER%%/${DSTUSER}/g" launch.sh
sudo mv launch.sh /srv/jupyter/launch.sh
sudo chmod 755 /srv/jupyter/launch.sh

mkdir /home/${DSTUSER}/.jupyter
jupyter-notebook --generate-config --allow-root
cd /home/${DSTUSER}/.jupyter
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj "/C=UK/ST=London/L=London/O=University College London/OU=Institute of Nuclear Medicine/CN=." \
-keyout mycert.pem -out mycert.pem 

bash /tmp/jupyter_set_pwd.sh ${JUPPWD}

echo "c= get_config()" >> jupyter_notebook_config.py
echo "c.NotebookApp.certfile = u'/home/${DSTUSER}/.jupyter/mycert.pem'" >> jupyter_notebook_config.py

NEWPWD=`cat ~/.jupyter/jupyter_notebook_config.json | grep password | cut -d'"' -f4`
echo "c.NotebookApp.password = u'${NEWPWD}'" >> jupyter_notebook_config.py

echo "c.NotebookApp.ip = '*'" >> jupyter_notebook_config.py
echo "c.NotebookApp.port = ${JUPPORT}" >> jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> jupyter_notebook_config.py
echo "c.NotebookApp.allow_remote_access = True" >> jupyter_notebook_config.py
