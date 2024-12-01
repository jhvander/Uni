# IS-LM Model Stability Analysis of the Equilibrium Point for a Closed Economy

Our project is titled **IS-LM Model Stability Analysis of the Equilibrium Point for a Closed Economy** and in this project, we will model the stability of the investment-savings (IS) liquidity preference-money supply (LM) model, which is inspired by, $\textit{Nascimento, A. et.al. (2019)}$. They find that the equilibrium point of the dynamic IS-LM model is asymptotically stable for any variation in its parameters. Therefore, we will try to replicate their results and assess whether or not we can confirm their findings. 

The **results** of the project can be seen from running [IS-LM.ipynb](IS-LM.ipynb) and uses functions defined in [ISLM.py](ISLM.py)

**Dependencies:** The project requires follwing packages: 
import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
from ipywidgets import interactive, fixed
import ipywidgets as widgets
from ipywidgets import interact, FloatSlider
