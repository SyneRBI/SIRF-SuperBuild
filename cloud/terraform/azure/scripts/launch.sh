#!/bin/bash

source /home/%%TARGETUSER%%/.sirfrc
exec jupyter-notebook --config=/home/%%TARGETUSER%%/.jupyter/jupyter_notebook_config.py
