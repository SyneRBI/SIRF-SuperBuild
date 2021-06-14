echo "create jupyter configuration"
source /opt/pyvenv/bin/activate

if [ ! -f ~/.jupyter/jupyter_notebook_config.py ]; then
  jupyter notebook --generate-config
  echo "c.NotebookApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> ~/.jupyter/jupyter_notebook_config.py
  echo "c.NotebookApp.notebook_dir = '/devel'" >> ~/.jupyter/jupyter_notebook_config.py
fi

# # https://jupyterhub.readthedocs.io/en/stable/reference/config-user-env.html#configuring-jupyter-and-ipython
# if [ ! -f /opt/pyvenv/etc/jupyter/jupyter_notebook_config.py ]; then
#   cp ~/.jupyter/jupyter_notebook_config.py /opt/pyvenv/etc/jupyter/jupyter_notebook_config.py
# fi