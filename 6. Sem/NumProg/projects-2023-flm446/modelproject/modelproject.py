from scipy import linalg
from types import SimpleNamespace

import numpy as np
import sympy as sm

import matplotlib.pyplot as plt
plt.rcParams.update({"axes.grid":True,"grid.color":"black","grid.alpha":"0.25","grid.linestyle":"--"})
plt.rcParams.update({'font.size': 14})

class ModelClass:

    def __init__(self, periods = 100):
        """ 
        Initializes ModelClass. Creates namespaces for the parameters, shocks and simulation results. Sets number of periods for simulation.

        Args:

            periods (int): number of periods for simulation 

        """

        # a. number of periods
        self.N = periods

        self.par = par = SimpleNamespace()
        self.shock = shock = SimpleNamespace()
        self.sim = sim = SimpleNamespace()
    
        # b. equilibrium values
        par.y_bar = 2
        par.pif = 2
        par.rf = np.linspace(2,2,self.N)
        par.if_ = 2

        # c. centralbank parameters
        par.b = 0.5
        par.h = 0.5
        par.lambda_ = 0.5

        # d. model parameters
        par.theta = 1
        par.gamma = 0.3
        par.beta1 = 0.7
        par.beta2 = 0.7
        par.beta_hat = par.b*par.beta1 + par.b*par.beta2*par.lambda_ + par.b * par.beta2*par.theta + par.lambda_ + par.theta
        
        # e. shocks
        shock.z_short = np.empty(self.N)
        shock.s_short = np.empty(self.N)

        # f. for storing simulation results
        sim.y = np.empty(self.N)
        sim.pi = np.empty(self.N)
        sim.er = np.empty(self.N)
        sim.i = np.empty(self.N)
        sim.e = np.empty(self.N)

    def solve_analytical(self):
        """ Analytically derives the AD curve from the temporary AD curve"""

        # a. define symbols
        y = sm.symbols("y")
        ybar= sm.symbols("ybar")
        beta1= sm.symbols("beta_1")
        er1= sm.symbols("e^{r}_{-1}")
        pi = sm.symbols("pi")
        pif = sm.symbols("pi^f")
        theta= sm.symbols("theta")
        h = sm.symbols("h")
        b = sm.symbols("b")
        lambda_ = sm.symbols("lambda")
        e = sm.symbols("e")
        e1 = sm.symbols("e_{-1}")
        beta2 = sm.symbols("beta_2")
        rf = sm.symbols("r^f")
        rbarf = sm.symbols("rbar^f")
        ztilde = sm.symbols("ztilde")

        # b. temporary AD curve
        AD_temp = sm.Eq(y - ybar, beta1 * (er1 - (pi - pif) - (1/(theta+lambda_))* (h* (pi -pif) + b* (y - ybar))) 
                        - beta2 * ( h * (pi - pif) + b * (y - ybar) + lambda_ * (e - e1) + rf - rbarf) + ztilde
                        )

        # c. solve temporary AD curve for pi
        AD_temp2 = sm.solve(AD_temp, pi)

        # d. AD curve 
        AD = sm.Eq(pi, AD_temp2[0])
        display(AD)       
     
    def short_run(self, h, b , lambda_ , gamma, theta, beta1, beta2 , shocks = True):
        """ Simulates the model
        
        Args:

            h (float): centralbank parameter
            b (float): centralbank parameter
            lambda_ (float): centralbank parameter
            gamma (float): slope of AS curve
            theta (float): related to exchange rate expectations
            beta1 (float): effect of the real exchange rate on the output gap
            beta2 (float): effect of the real interest rate gap on the output gap
            shock (boolean): If False, all shocks are zero
        """

        # a. assign namespaces
        par = self.par
        shock = self.shock
        sim = self.sim

        # b. assign parameter values
        par.h = h
        par.b = b
        par.lambda_ = lambda_
        par.gamma = gamma
        par.theta = theta
        par.beta1 = beta1
        par.beta2 = beta2
        
        np.random.seed(1547)
        
        # c. simulate model
        for i in range(self.N):

            # i. first period
            if i == 0:
                sim.y[i] = par.y_bar
                sim.pi[i] = par.pif
                sim.er[i] = 0
                sim.i[i] = par.rf[i] + par.pif
                sim.e[i] = 0
                shock.z_short[i] = 0
                shock.s_short[i] = 0

            # ii. other periods
            else:
                
                # o. shocks
                if shocks is True:
                    shock.z_short[i] = 0.9*shock.z_short[i-1] + 0.5 * np.random.normal()
                    shock.s_short[i] = 0.9*shock.s_short[i-1] + 0.5 * np.random.normal()

                else:
                    shock.z_short[i] = 0
                    shock.s_short[i] = 0

                # oo. matrices for the linear equation system
                A = np.array([ [par.b , par.h , par.lambda_ , -1] 
                              , [par.b/(par.theta+par.lambda_), par.h/(par.theta+par.lambda_) , 1, 0]
                              , [-par.gamma, 1,0,0] 
                              , [(par.b*par.beta1 + par.b*par.beta2*par.lambda_ + par.b*par.beta2*par.theta+par.lambda_+par.theta)/par.beta_hat
                              , 1 , par.beta2*par.lambda_**2 + par.beta2*par.lambda_*par.theta,0] 
                              ])
                
                B = np.array([ [par.pif * (par.h-1) + par.b*par.y_bar + par.lambda_*sim.e[i-1] - par.rf[i]]
                              , [sim.e[i-1] + (par.h/(par.theta+par.lambda_))*par.pif + (par.b/(par.theta+par.lambda_))*par.y_bar]
                              , [par.pif-par.gamma*par.y_bar+shock.s_short[i]]
                              , [((par.b*par.beta1 + par.b*par.beta2*par.lambda_ + par.b*par.beta2*par.theta + par.lambda_ + par.theta)/par.beta_hat)*par.y_bar 
                                 + (par.beta1*par.lambda_ + par.beta1*par.theta)*sim.er[i-1] 
                                 + (par.beta2*par.lambda_**2 + par.beta2*par.lambda_*par.theta)*sim.e[i-1] + (par.lambda_+par.theta)*shock.z_short[i]+par.pif]
                                 ]) 

                # ooo. solution and results
                sol = linalg.solve(A,B)
                sim.y[i], sim.pi[i], sim.e[i], sim.i[i] = sol
                sim.er[i] = sim.er[i-1] - (sim.pi[i]- par.pif) - (1/(par.theta+par.lambda_)) * (par.h * (sim.pi[i] - par.pif) + par.b*(sim.y[i] - par.y_bar))


        # d. creates figure
        periods = np.linspace(0,self.N,self.N)
        fig = plt.figure()

        y = fig.add_subplot(5,1,1)
        pi = fig.add_subplot(5,1,2)
        i = fig.add_subplot(5,1,3)
        er = fig.add_subplot(5,1,4)
        e = fig.add_subplot(5,1,5)

        # e. plots variables
        y.plot(periods, sim.y)
        y.set_title("y")

        pi.plot(periods, sim.pi)
        pi.set_title("$\pi$")

        i.plot(periods, sim.i)
        i.set_title("i")

        er.plot(periods, sim.er)
        er.set_title("$e^r$")
            
        e.plot(periods, sim.e)
        e.set_title("e")

        fig.set_size_inches(12,15)
        fig.subplots_adjust(hspace = 0.4)
        
        plt.show()
      
                
    