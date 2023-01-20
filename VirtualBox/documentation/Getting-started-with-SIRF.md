# Running SIRF
We need 2 things: the gadgetron server needs to run, and we need a python client.
## Starting gadgetron
Open a terminal and type

    gadgetron

and leave this running.

## Python from the command line
Open another terminal and type for instance
```bash
cd $SIRF_PATH
cd examples/Python/MR
ls
python3 fully_sampled_recon.py
```
or to get some help
```bash
python3 fully_sampled_recon.py --help
```

## Using Spyder
You will want to see what the demos are doing. One way is to use [Spyder](https://pythonhosted.org/spyder/#).
Spyder is no longer installed by default, but you can do this yourself with `pip` using the python that has been used to build SIRF, i.e. python3.
```bash
python3 -m pip install spyder
```
Of course, feel free to install another Python IDE instead.

You can then start it from a terminal like this
```bash
cd $SIRF_PATH
cd examples/Python/MR
spyder fully_sampled_recon.py&
```
You should then be able to get going by using the menus etc. More information is on 
http://www.southampton.ac.uk/~fangohr/blog/spyder-the-python-ide.html from which we quote some text here:

Useful shortcuts in the Spyder editor (these are in Windows-style, including the usual copy-paste shortcuts Left-CTRL-C and Left-CTRL-V):
- `F9` executes the currently highlighted code (NOTE: if the script contains the line `args = docopt(__doc__, version=__version__)`, then your first executed piece should include all lines from the first to this line).
- `LEFT-CTRL + <RETURN>` executes the current cell (menu entry Run -> Run cell). A cell is defined as the code between two lines which start with the agreed tag #%%.
- `SHIFT + <RETURN>` executes the current cell and advances the cursor to the next cell (menu entry Run -> Run cell and advance).
- `TAB` tries to complete the word/command you have just typed.

The Spyder Integrated Development Environment (IDE) has of course lots of parameters which you can tune to your liking. The main setting that you might want to change is if the graphics are generated “inline” in the iPython console, or as separate windows. Go to Tools > Preferences > iPython console > Graphics > Graphics backend. Change from “inline” to “automatic” if you prefer the separate windows or vice versa.

## Running the SIRF Exercises
The VM also contains the [SIRF exercises](https://github.com/SyneRBI/SIRF-Exercises/). Please check the [README](https://github.com/SyneRBI/SIRF-Exercises/blob/master/README.md).

SIRF-Exercises uses jupyter notebooks. The SIRF VM contains a jupyter notebook server. To start you need to issue the following two commands in two separate terminal windows.

```
gadgetron
jupyter lab
```

The jupyter notebook will be accessible with a browser on the host machine pointing to `http://localhost:8888` The password is `virtual`.
More info is available in the links above.

## Basic Python info

Here is some suggested material on Python (ordered from easy to quite time-consuming).

- The official Python tutorial. Just read Section 1, 3, a bit of 4 and a tiny bit of 6.
https://docs.python.org/2/tutorial/
- Examples for matplotlib, the python module that allows you to make plots almost like in MATLAB
https://github.com/patvarilly/dihub-python-for-data-scientists-2015/blob/master/notebooks/02_Matplotlib.ipynb
- You could read bits and pieces of Python the Hard Way
http://learnpythonthehardway.org/book/index.html
- Google has an online class on Python for those who know some programming. This goes quite in depth and covers 2 days.
https://developers.google.com/edu/python/?csw=1

One thing which might surprise you that in Python indentation is important. You would write for instance
```Python
for z in range(0,image.shape[0]):
   plt.figure()
   plt.imshow(image[z,:,:])
# now do something else
```
