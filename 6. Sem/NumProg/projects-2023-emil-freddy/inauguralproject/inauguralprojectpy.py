# Importing all required packages for our project
from types import SimpleNamespace

import numpy as np
from scipy import optimize
from scipy.optimize import minimize

import pandas as pd 
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d

# Setting up our model, the class
class HouseholdSpecializationModelClass:

    def __init__(self):
        """ setup model """

        # a. create namespaces
        par = self.par = SimpleNamespace()
        sol = self.sol = SimpleNamespace()
        opt = self.opt = SimpleNamespace()

        # b. preferences
        par.rho = 2.0
        par.nu = 0.001
        par.epsilon = 1.0
        par.omega = 0.5 

        # c. household production
        par.alpha = 0.5
        par.sigma = 1.0

        # d. wages
        par.wM = 1.0
        par.wF = 1.0
        par.wF_vec = np.linspace(0.8,1.2,5)

        # e. targets
        par.beta0_target = 0.4
        par.beta1_target = -0.1

        # f. solution
        sol.LM_vec = np.zeros(par.wF_vec.size)
        sol.HM_vec = np.zeros(par.wF_vec.size)
        sol.LF_vec = np.zeros(par.wF_vec.size)
        sol.HF_vec = np.zeros(par.wF_vec.size)

        sol.beta0 = np.nan
        sol.beta1 = np.nan


    def calc_utility(self,LM,HM,LF,HF):
        """ calculate utility """

        par = self.par
        sol = self.sol

        # a. consumption of market goods
        C = par.wM*LM + par.wF*LF

        # b. home production 
        #H = HM**(1-par.alpha)*HF**par.alpha
        H = None
        if (par.sigma == 1):
            H = HM**(1-par.alpha)*HF**par.alpha
        elif (par.sigma == 0):
            H = min(HM,HF)
        else:
            H = ((1-par.alpha)*HM**((par.sigma-1)/par.sigma)+par.alpha*HF**((par.sigma-1)/par.sigma))**(par.sigma/(par.sigma-1))

        # c. total consumption utility
        Q = C**par.omega*H**(1-par.omega)
        utility = np.fmax(Q,1e-8)**(1-par.rho)/(1-par.rho)

        # d. disutlity of work
        epsilon_ = 1+1/par.epsilon
        TM = LM+HM
        TF = LF+HF
        disutility = par.nu*(TM**epsilon_/epsilon_+TF**epsilon_/epsilon_)
        
        return utility - disutility


    def solve_discrete(self,do_print=False):
        """ solve model discretely """
        
        par = self.par
        sol = self.sol
        opt = self.opt 
        
        # a. all possible choices
        x = np.linspace(0,24,49)
        LM,HM,LF,HF = np.meshgrid(x,x,x,x) # all combinations
    
        LM = LM.ravel() # vector
        HM = HM.ravel()
        LF = LF.ravel()
        HF = HF.ravel()

        # b. calculate utility
        u = self.calc_utility(LM,HM,LF,HF)
    
        # c. set to minus infinity if constraint is broken
        I = (LM+HM > 24) | (LF+HF > 24) # | is "or"
        u[I] = -np.inf
    
        # d. find maximizing argument
        j = np.argmax(u)
        
        opt.LM = LM[j]
        opt.HM = HM[j]
        opt.LF = LF[j]
        opt.HF = HF[j]

        # e. print
        if do_print:
            for k,v in opt.__dict__.items():
                print(f'{k} = {v:6.4f}')

        return opt

        
    def solve_continuous(self, do_print=False):
        """solve the model using continuous optimization"""
        par = self.par
        sol = self.sol
        opt = self.opt
        # Define the objective function to be minimized
        def objective(x):
            LM, HM, LF, HF = x
            return -self.calc_utility(LM, HM, LF, HF)
        
        # Define the constraint functions
        def constraint1(x):
            LM, HM, LF, HF = x
            return 24 - (LM + HM)
        
        def constraint2(x):
            LM, HM, LF, HF = x
            return 24 - (LF + HF)
        
        # Define the initial guess for the decision variables
        x0 = [6, 6, 6, 6]
        
        # Define the bounds for the decision variables
        bounds = ((0, 24), (0, 24), (0, 24), (0, 24))
        
        # Define the constraints
        cons = [{'type': 'ineq', 'fun': constraint1},
                {'type': 'ineq', 'fun': constraint2}]
        
        # Solving the optimization problem with method Nelder-Mead
        opt = optimize.minimize(objective, x0, method='Nelder-Mead', bounds=bounds, constraints=cons)
        
        # Saving the optimal decision variables
        opt.LM = opt.x[0]
        opt.HM = opt.x[1]
        opt.LF = opt.x[2]
        opt.HF = opt.x[3]
         
        # Printing the results
        if do_print:
            for k, v in sol.__dict__.items():
                print(f"{k} = {v:6.4f}")
        
        return opt
        
    
    def solve_wF_varying(self,discrete=False):
        """ solve model for vector of female wages """
        sol = self.sol
        par = self.par

        for i, w_F in enumerate(par.wF_varying):
            par.wF = w_F
            if discrete:
                opt = self.solve_discrete()
            else:
                opt = self.solve()
            if opt is not None:
                sol.LM_vec[i], sol.HM_vec[i], sol.LF_vec[i], sol.HF_vec[i] = opt.LM, opt.HM, opt.LF, opt.HF
        pass


    def run_regression(self):
        """ run regression """

        par = self.par
        sol = self.sol

        x = np.log(par.wF_vec)
        y = np.log(sol.HF_vec/sol.HM_vec)
        A = np.vstack([np.ones(x.size),x]).T
        sol.beta0,sol.beta1 = np.linalg.lstsq(A,y,rcond=None)[0]


    def solve_wF_vec(self,discrete=False):
        #used to illustrate question 4

        sol = self.sol
        par = self.par
        opt = self.opt

        # a. Creating vectors to store later results. These are initialized by 0
        opt.logHFHM = np.zeros(par.wF_vec.size)
        opt.HF_vec = np.zeros(par.wF_vec.size)
        opt.HM_vec = np.zeros(par.wF_vec.size)
        opt.LF_vec = np.zeros(par.wF_vec.size)
        opt.LM_vec = np.zeros(par.wF_vec.size)


        for i, w_F in enumerate(par.wF_vec):
            par.wF = w_F
            if discrete:
                opt2 = self.solve_discrete()
            else:
                opt2 = self.solve_continuous()
            if opt2 is not None:
                sol.LM_vec[i], sol.HM_vec[i], sol.LF_vec[i], sol.HF_vec[i] = opt2.LM, opt2.HM, opt2.LF, opt2.HF

            # ii. We then store the results 
            opt.logHFHM[i] = np.log(opt2.HF/opt2.HM)
            opt.HM_vec[i] = opt2.HM
            opt.HF_vec[i] = opt2.HF
            opt.LF_vec[i] = opt2.LF
            opt.LM_vec[i] = opt2.LM
        return opt

    
    

    def estimate(self, alpha=None):
        """ estimate alpha and sigma for variable and fixed alpha """
        par = self.par
        sol = self.sol
        opt = self.opt

        def objective_function(x):
                par.alpha = x[0]
                par.sigma = x[1]
                self.solve_wF_vec()
                self.run_regression()
                return (par.beta0_target - sol.beta0) ** 2 + (
                            par.beta1_target - sol.beta1) ** 2

     # Some Bounds and some intial guess. The values are not essentiel, it just take longer to run, if they are less restrictive.
        bnds = [(0,1), (0,1)] #alpha between 0 and 1, sigma between 0 and 1

        initial_guess = [0.99, 0.1]
        # ii. optimizer
        result = optimize.minimize(objective_function, initial_guess,
                                       method='Nelder-Mead',
                                       bounds=bnds,
                                       tol=1e-10,
                                       )

        opt.result = result
        return opt.result
        

    def estimate_extended(self,sigma=None,epsilon_M=None,epsilon_F=None,extend=True):
        par = self.par
        opt = self.opt
        sol = self.sol

        if extend==True:
            def dif2(x):
                par = self.par #Calls upon the parameters
                opt = self.opt #Calls upon the optimizer
                par.sigma = x[0] 
                par.epsilon_F = x[1]
                self.solve_wF_vec() #Calls upon female wage solver to solve 
                self.run_regression() #Runs the regression 
                dif = (sol.beta0 - par.beta0_target)**2 + (sol.beta1 - par.beta1_target)**2 #Finds the difference
                return dif
        
            result2 = optimize.minimize(dif2, [sigma,epsilon_F], bounds=[(0.01,5.0),(0.01,5.0)], method='Nelder-Mead') #Minimizes sigma and epsilon_f
            opt.sigma = result2.x[0] #Stores the results
            opt.epsilon_F = result2.x[1]

            return opt
        
        elif extend==False:
            def dif(x):
                par = self.par
                opt = self.opt
                par.sigma = x[0]
                self.solve_wF_vec() 
                self.run_regression()
                dif = (sol.beta0 - par.beta0_target)**2 + (sol.beta1 - par.beta1_target)**2  
                return dif
        
            result = optimize.minimize(dif, [sigma], bounds=[(0.2,5.0)], method='Nelder-Mead')
            opt.sigma = result.x[0]

            return opt