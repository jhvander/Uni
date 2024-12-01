---
title: "Installation"
date: 2024-06-17
weight: 3
next: post/jupyter
prev: post/assignment

---

This class will involve a lot of coding, for which you will need some basic tools.

1. [Python, Jupyter Notebook and JupyterLab](#python-jupyter-notebook-and-jupyterlab)
2. [A git client](#a-git-client)
3. [A github account](#a-github-account)

We will discuss these tools in much more detail in class, so don't worry if this is all new and perhaps a bit frightening right now.


## Python, Jupyter Notebook and JupyterLab

[Python](https://www.python.org/) is a free programming language. We will use the distribution called [Anaconda](https://docs.anaconda.com/anaconda/) as it comes with the most essential for working with data, statistical computing and visualizations. We will use Anaconda with Python 3 throughout the course, so please make sure it is installed on your computer before first day of class. It works on all platforms.

Anaconda can be downloaded [here](https://www.anaconda.com/download), for Windows, Mac or Linux.
If you want to watch a step-by-step tutorial on how to install Anaconda for you machine see the guides here:

- Install Anaconda for Windows by [following these steps](https://docs.anaconda.com/anaconda/install/windows/) or [watch this video](https://www.youtube.com/watch?v=Vt6loGK9Adc)
- Install Anaconda for Mac by [following these steps](https://docs.anaconda.com/anaconda/install/mac-os/) or [watch this video](https://www.youtube.com/watch?v=OOFONKvaz0A)

Since the vast majority of our coding will be in the Python language, we will use an integrated development environment ([IDE](https://en.wikipedia.org/wiki/Integrated_development_environment)). IDEs integrate text editing, syntax highlighting, and version control, simplifying the coding process. All this is automatically included in Anaconda through [Jupyter](https://jupyter.org). It's free and modern, and if you're new to Python this will make it much easier to get started. All Python coding in this course will be done in Jupyter notebooks either through the classic Jupyter Notebook interface or JupyterLab (see below).

[Project Jupyter](https://jupyter.org/) has an extended IDE, [JupyterLab](https://jupyterlab.readthedocs.io/en/stable/getting_started/overview.html), that works with Jupyter notebooks (`.ipynb` files) in the [same way](https://jupyterlab.readthedocs.io/en/stable/user/notebook.html) as the classic Jupyter Notebook interface does. The JupyterLab interface provides severable extensions on top of the classic notebook experience. Among others, it has a sidebar which contains a [file browser](https://jupyterlab.readthedocs.io/en/stable/user/files.html) for easier navigation of project files and a ready to use [dark mode theme](https://docs.qubole.com/en/latest/user-guide/notebooks-and-dashboards/notebooks/jupyter-notebooks/themes-jupy.html), see [here](https://jupyterlab.readthedocs.io/en/stable/user/interface.html) for more features. As of 2022, the classic Jupyter Notebook interface will eventually be [replaced](https://jupyterlab.readthedocs.io/en/stable/getting_started/overview.html#releases) by the newer JupyterLab interface. Therefore, it is recommended that one uses JupyterLab to work with the notebook files in this course. However, it is perfectly fine to use the classic Jupyter Notebook interface if one prefers.

#### Verifying the installation

After installation of Python please execute a number of commands in your shell to check if everything is working. You need to first open your local shell, this is either the `Anaconda Prompt` (all operating systems), `cmd` on Windows or `terminal` on Linux/Mac. See details [here](https://docs.anaconda.com/anaconda/user-guide/getting-started/). Once the shell is open type `python` - this will start Python. Once you have Python started please check if the version of Python is at least 3.9. 
Next, try the following two commands to verify that it's working.

```python
1 + 2
>>> 3
```

```python
print('Welcome to Introduction to Social Data Science')
>>> Welcome to Introduction to Social Data Science
```

#### Welcome to open source
To know core Python is powerful in itself, but the great potentials lie in the huge community of developers and researchers contributing to a shared pool of software packages. A programming language is as powerful as the community that surrounds it. Especially in the field of machine learning, the Python community is leading the way, allowing you to share code with top researchers from the field and industry, among others Google's top engineering teams. Tapping into these vast resources is made easy by the Conda distribution and the pip package manager. Just open your shell/command-line/terminal and type the following: `conda install [name of package]`
or, if conda does not support it directly, use the more generic package manager: 
`pip install [name of package]`


#### Using notebooks through the classic Jypyter Notebook interface
The [Jupyter Notebook App](https://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/what_is_jupyter.html#notebook-app) can be launched by typing the following either in the `Anaconda Prompt`, a terminal (on Mac/Linux) or cmd (on Windows).

`jupyter notebook`

This will launch a new browser window (or a new tab) showing the Notebook Dashboard, a sort of control panel that allows (among other things) to select which notebook to open.


#### Using notebooks through JypyterLab
[JupyterLab](https://jupyterlab.readthedocs.io/en/stable/getting_started/starting.html) can be launched by typing the following either in the `Anaconda Prompt`, a terminal (on Mac/Linux) or cmd (on Windows).

`jupyter lab`

This will launch a new browser window (or a new tab) showing a control panel similar to the classic Jupyter Notebook that, besides the same as the classic notebook interface, allows to browse the project files through the file browser. Note that the classic notebook interface can always be reached through JupyterLab by clicking on [Help] in the menu bar and then [Launch Classic Notebook]. 

#### Getting friendly with Jupyter

Try to spend a little time familiarizing yourself with the Jupyter framework. For instance, try learning a few of your editor's keyboard shortcuts; see our post [here](/isds2024/post/jupyter/). The point is to be as productive as possible when working with the computer. Karl Broman, a professor of biostatistics and medical informatics at the University of Wisconsin-Madison, gives some great advice for working with code:

> The key thing I emphasize to students is they should be using the mouse as little as possible. Every time you move your hands away from the keys, you're slowing yourself down.



## A Git client

[Git](https://git-scm.com/) is a version control system that allows you to track modifications to files and code over time. It also facilitates collaborations so that multiple people can share and edit the same code base.

If you are on Windows you can install [Github Desktop](https://desktop.github.com) which provides both the command line tool for git and a graphical user interface. Alternatively, you can install Git as an optional package under Cygwin. I recommend the Github application, as it will be easier to interface with GitHub using it. Likewise, modern versions of Mac OS X have a command line Git client installed by default, but the [Github Desktop](https://desktop.github.com) tool is a recommended addition.

## A Github account

[Github](http://github.com) is a platform that facilitates collaboration on projects that use git. You can use it to host projects, publish them to the web, and share them with other people. [Create a free account](https://help.github.com/articles/signing-up-for-a-new-github-account/) if you don't already have one.

Once you have an account, clone the [course repository](https://github.com/isdsucph/isds2024) using your local git client. This is most easily done on the command line as follows:

```
    # git clone https://github.com/abjer/isds2024
	Cloning into 'isds2024'...
	remote: Counting objects: 145, done.
	remote: Compressing objects: 100% (98/98), done.
	remote: Total 145 (delta 40), reused 137 (delta 37)
	Receiving objects: 100% (145/145), 454.90 KiB | 594.00 KiB/s, done.
	Resolving deltas: 100% (40/40), done.
	Checking connectivity... done.
```

When this is complete, verify that you have a local directory called ``isds2024`` containing a ``README.md`` file.

Afterwards you can subscribe to updates, small and big, by using `Watch` or `Star` within the GitHub page.


## A text editor (optional)

An important alternative to Jupyter is a decent text editor. A text editor is a program that lets you work with plain-text files. You should pick an editor capable of syntax highlighting, syntax checking (ensuring that brackets and parentheses are properly paired), and handling multiple files. We highly recommend:

- [VSCode](https://code.visualstudio.com/) or [Atom](https://atom.io/)

Another good option is [Sublime Text](http://www.sublimetext.com/).

All three of these can be extended by installing "packages". No matter your choice of editor, it is a good idea to find and install extensions that are designed to help you with Python programming.