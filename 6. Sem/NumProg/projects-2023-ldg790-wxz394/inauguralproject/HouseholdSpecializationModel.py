
from types import SimpleNamespace

import numpy as np
from scipy import optimize

import pandas as pd 
import matplotlib.pyplot as plt

class HouseholdSpecializationModelClass:

    def __init__(self):
        """ setup model """

        # a. create namespaces
        par = self.par = SimpleNamespace() #indeholder parameter
        sol = self.sol = SimpleNamespace() #indeholder solutions

        # b. preferences
        par.rho = 2.0
        par.nu = 0.001
        par.epsilon = 1.0
        par.omega = 0.5 


        # Extension of the model for question 5
        par.theta = 0.0

        # c. household production
        #par.alpha = np.array([0.5, 0.25, 0.75])
        #par.sigma = np.array([0.1, 0.5, 1.5])
        par.alpha = 0.5
        par.sigma = 0.1
        # d. wages
        par.wM = 1.0
        par.wF = 1.0
        par.wF_vec = np.array([0.8,0.9,1.0,1.1,1.2])

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
        

       # Defining the home production function for different values of sigma
        if par.sigma == 0:
            H = min(HM,HF)
        elif par.sigma == 1:
            H= HM**(1-par.alpha)*HF**par.alpha
        else:
            H = ((1-par.alpha)*HM**((par.sigma-1)/par.sigma)+par.alpha*HF**((par.sigma-1)/par.sigma))**((par.sigma)/(par.sigma-1)) 

        # c. total consumption utility
        Q = C**par.omega*H**(1-par.omega)
        utility = np.fmax(Q,1e-8)**(1-par.rho)/(1-par.rho)

        # d. disutlity of work
        epsilon_ = 1+1/par.epsilon
        TM = LM+HM
        TF = LF+HF
        disutility = par.nu*((TM+HM*par.theta)**epsilon_/epsilon_+(TF)**epsilon_/epsilon_)
        
        return utility - disutility

    def solve_discrete(self,do_print=False):
        """ solve model discretely """
        
        par = self.par
        sol = self.sol
        opt = SimpleNamespace()

        # a. all possible choices
        x = np.linspace(0,24,49)
        LM,HM,LF,HF = np.meshgrid(x,x,x,x) # all combinations
    
        LM = LM.ravel() #returns a flattened array
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

    def solve(self,do_print=False):
        """ solve model continously """

        # Creates an empty object of the "SimpleNamespace" class
        opt = SimpleNamespace()

        # Defines the objective function as the negative of the utility function
        def objective(x):
            LM, HM, LF, HF = x
            return -self.calc_utility(LM, HM, LF, HF)

        # Defines the constraints as the sum of LM and HM, and the sum of LF and HF, where both must be less than or equal to 24
        def constraints(x):
            LM, HM, LF, HF = x
            return [24 - LM - HM, 24 - LF - HF]
        
        # Sets the bounds of the decision variable to be between 0 and 24
        constraints = ({'type':'ineq', 'fun': constraints})
        bounds = ((0,24),(0,24),(0,24),(0,24))

        # The initial guess for the decision variables:
        guess = [6, 6, 6, 6]

        # Calls the 'minimize()' function and the SLSQP algorithm is used to solve
        solution = optimize.minimize(
            objective, guess, 
            method='Nelder-Mead', 
            bounds=bounds, 
            constraints=constraints
            )
        
        # Optimal values for the decision variables are assigned
        opt.LM, opt.HM, opt.LF, opt.HF = solution.x

        return opt
   

    def solve_wF_vec(self):
            """ solve model for vector of female wages """
            # first we assign the value of the par and sol attributes
            par = self.par
            sol = self.sol

            # loops over each element of the wF_vec
            for i, wF in enumerate(par.wF_vec):
                par.wF = wF
                opt= self.solve() # calls the solve() function and assigns the output to the opt variable
                sol.HF_vec[i] = opt.HF
                sol.HM_vec[i] = opt.HM
                sol.LF_vec[i] = opt.LF
                sol.LM_vec[i] = opt.LM
            
            return sol.HF_vec, sol.HM_vec, sol.LF_vec, sol.LM_vec

    # performs a linear regression                
    def run_regression(self):
        """ run regression """

        par = self.par
        sol = self.sol

        x = np.log(par.wF_vec) #Takes log of wF_vec
        y = np.log(sol.HF_vec/sol.HM_vec)
        A = np.vstack([np.ones(x.size),x]).T #creates a matrix with ones equal to the length of x.
        sol.beta0,sol.beta1 = np.linalg.lstsq(A,y,rcond=None)[0] #uses the least squares method to find the best fit line of y onto A.
        return sol.beta0, sol.beta1
    
    def estimate(self,alpha=None,sigma=None):
        """ estimate alpha and sigma """
        
        par = self.par
        sol = self.sol

        # define objective function to minimize
        def objective(x):
            alpha, sigma = x
            par.alpha = alpha
            par.sigma = sigma
            self.solve_wF_vec()
            self.run_regression()
            return (par.beta0_target - sol.beta0)**2+(par.beta1_target - sol.beta1)**2
        
        # initial guess
        guess = [0.5, 1]

        # call solver
        solution = optimize.minimize(objective, guess, method='Nelder-Mead')

        alpha, sigma = solution.x

        return alpha, sigma



    def estimateV2(self,alpha=None,sigma=None):
        """ estimate alpha and sigma """
        
        par = self.par
        sol = self.sol

        # define objective function to minimize
        def objective(x):
            alpha, sigma = x
            par.alpha = 0.5
            par.sigma = sigma
            self.solve_wF_vec()
            self.run_regression()
            return (par.beta0_target - sol.beta0)**2+(par.beta1_target - sol.beta1)**2
        
        # initial guess
        guess = [0.5, 1]

        # call solver
        solution = optimize.minimize(objective, guess, method='Nelder-Mead')

        alpha, sigma = solution.x

        return alpha, sigma


    def estimateV3(self,sigma=None):
        """ estimate alpha and sigma """
        def objective(x, self):
            par = self.par
            sol=self.sol
            par.theta = x[0] #Incorporates the theta value into the par object
            par.sigma = x[1]
            self.solve_wF_vec()
            self.run_regression()
            return (0.4-sol.beta0)**2+(-0.1-sol.beta1)**2
        guess = [(1.4)]*2
        bounds = [(0,30)]*2
        result = optimize.minimize(objective, guess, args = (self), method = 'Nelder-Mead', bounds=bounds)