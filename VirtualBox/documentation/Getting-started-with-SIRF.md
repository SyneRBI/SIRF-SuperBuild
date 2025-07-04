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

## Using a Python IDE
You will want to see what the demos are doing. One way is to use [Spyder](https://docs.spyder-ide.org/current/installation.html).
Of course, feel free to install another Python IDE instead.

You can then start it from a terminal like this
```bash
cd $SIRF_PATH
cd examples/Python/MR
spyder fully_sampled_recon.py&
```

## Running the SIRF Exercises
The VM also contains the [SIRF exercises](https://github.com/SyneRBI/SIRF-Exercises/). Please check the [README](https://github.com/SyneRBI/SIRF-Exercises/blob/master/README.md).

SIRF-Exercises uses jupyter notebooks. The SIRF VM contains a jupyter notebook server. After starting `gadgetron` as above, type the following command in a new terminal window:

```
jupyter lab --no-browser
```

The jupyter notebook will be accessible with a browser on the host machine pointing to `http://localhost:8888` The password is `virtual` (although you might not need to enter it).
More info is available in the links above.

Note that you can choose to install a browser inside the VM and access the server directly
from there. In this case, you will have to do for instance
```
jupyter lab --browser firefox
```

## Basic Python info

Here is some suggested material on Python (ordered from easy to quite time-consuming).

- The official Python tutorial. Just read Section 1, 3, a bit of 4 and a tiny bit of 6:
https://docs.python.org/3/tutorial/
- Examples for matplotlib, the python module that allows you to make plots almost like in MATLAB:
https://matplotlib.org/stable/tutorials/index.html
- You could read bits and pieces of Python the Hard Way:
http://learnpythonthehardway.org/book/index.html
- Google has an online class on Python for those who know some programming. This goes quite in depth and covers 2 days:
https://developers.google.com/edu/python

One thing which might surprise you that in Python indentation is important. You would write for instance
```Python
for z in range(0,image.shape[0]):
   plt.figure()
   plt.imshow(image[z,:,:])
# now do something else
```
