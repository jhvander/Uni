
from types import SimpleNamespace

import numpy as np
from scipy import optimize

import pandas as pd 
import matplotlib.pyplot as plt

class HouseholdSpecializationModelClass:

    def __init__(self):
        """ setup model """

        # a. create namespaces
        par = self.par = SimpleNamespace()
        sol = self.sol = SimpleNamespace()

        # b. preferences
        par.rho = 2.0
        par.nu = 0.001
        par.epsilon = 1.0
        par.omega = 0.5 
        par.epsilon_M = 1.0
        par.epsilon_F = 1.0

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
        sol.LM_vec = np.empty(par.wF_vec.size)
        sol.HM_vec = np.empty(par.wF_vec.size)
        sol.LF_vec = np.empty(par.wF_vec.size)
        sol.HF_vec = np.empty(par.wF_vec.size)

        sol.beta0 = np.nan
        sol.beta1 = np.nan

    def calc_utility(self,LM,HM,LF,HF, question5 = False):
        """ calculate utility """

        par = self.par
        sol = self.sol

        # a. consumption of market goods
        C = par.wM*LM + par.wF*LF

        # b. home production
        if par.sigma == 1:
            H = HM**(1-par.alpha)*HF**par.alpha
        elif par.sigma == 0:
            H = np.fmin(HM,HF)
        else:
            H = np.fmax(( (1-par.alpha)*np.fmax(HM,1e-8)**( (par.sigma - 1) / par.sigma) + par.alpha*np.fmax(HF,1e-8)**( (par.sigma - 1) / par.sigma)  ) , 1e-8)** (par.sigma/ (par.sigma - 1)) 

    
        # c. total consumption utility
        Q = C**par.omega*H**(1-par.omega)
        utility = np.fmax(Q,1e-8)**(1-par.rho)/(1-par.rho)

        # d. disutlity of work
        TM = LM+HM
        TF = LF+HF
        if question5 is False:
            epsilon_ = 1+1/par.epsilon
            disutility = par.nu*(TM**epsilon_/epsilon_+TF**epsilon_/epsilon_)
        elif question5 is True:
            epsilon_ = 1+1/par.epsilon
            epsilon_F = 1 + 1/par.epsilon_F
            disutility = par.nu*(LM**epsilon_/epsilon_ + LF**epsilon_ /epsilon_ +  HF**epsilon_F/epsilon_F + HM**epsilon_/epsilon_)

        return utility - disutility

    def solve_discrete(self,do_print=False, question5 = False):

        """ solve model discretely """
        
        par = self.par
        sol = self.sol
        opt = SimpleNamespace()
        
        # a. all possible choices
        x = np.linspace(0,24,49)
        LM,HM,LF,HF = np.meshgrid(x,x,x,x) # all combinations
    
        LM = LM.ravel() # vector
        HM = HM.ravel()
        LF = LF.ravel()
        HF = HF.ravel()

        # b. calculate utility
        u = self.calc_utility(LM,HM,LF,HF, question5 = question5)
    
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
    
    def solve(self,do_print=False, question5 = False):
        """ solve model continously and returns a namespace for the solution  """

        par = self.par
        sol = self.sol
        opt_cont = SimpleNamespace()

        # a. function to minimize
        def value_of_choice(x):
            """ Calculates the negative of utility
            
            Args:

                x (list): Elements should be LM, HM, LF, HF
            
            Returns:

                (float): Negative of utility
            """
            return -self.calc_utility(x[0],x[1],x[2],x[3], question5 = question5)
        
        # b. constraints and bounds for minimization
        constraint1= ({'type': 'ineq', 'fun': lambda x: 24-x[0]-x[2]} )
        constraint2 = ({'type': 'ineq', 'fun': lambda x: 24-x[1]-x[3]} )
        constraints = (constraint1,constraint2)
        bounds = ((0,24), (0,24), (0,24), (0,24))

        # c. Variables to temporarily store results
        x_best = np.zeros(4)
        u_best = -np.inf
        
        # d. Find minimizing argument
        for x1 in np.linspace(0,8,2): # looping through different guesses, since it seems sensitive to the guess
            for x2 in np.linspace(0,8,2):
                for x4 in np.linspace(0,8,2):
                    
                    # i. Guess
                    x0 = [x1,x2,4,x4]

                    # ii. minmize
                    res = optimize.minimize(value_of_choice,x0, bounds = bounds, constraints = constraints, method = 'SLSQP' )
                   
                    # iii. Evaluate argument and utility
                    xopt = res.x
                    uopt = self.calc_utility(res.x[0],res.x[1],res.x[2],res.x[3])
                    if uopt > u_best:
                        x_best = xopt
                        u_best = uopt
                    

        # e. Assign minimizing argument to namespace
        opt_cont.LM = x_best[0]
        opt_cont.HM = x_best[1]
        opt_cont.LF = x_best[2]
        opt_cont.HF = x_best[3]

        return opt_cont
       
    def solve_wF_vec(self,discrete=False, question5 = False):
        """ solve model for vector of female wages and returns a list of namespaces of solutions"""
        par = self.par
        sol = self.sol

        # a. List for solutions
        opt_wF = [0.0 for x in range(par.wF_vec.size)]

        # b. Solve model 
        for i, w in enumerate(par.wF_vec):
            par.wF = w

            # i. Solve model discretely
            if discrete is True:
                opt_wF[i] = self.solve_discrete(question5 = question5)
            else:
                opt_wF[i] = self.solve(question5 = question5)
    
        # c. Assign results to solution arrays
        for i in range(5):
            sol.LM_vec[i] = opt_wF[i].LM
            sol.HM_vec[i] = opt_wF[i].HM
            sol.LF_vec[i] = opt_wF[i].LF
            sol.HF_vec[i] = opt_wF[i].HF

        return sol.HM_vec , sol.HF_vec

    def run_regression(self):
        """ run regression """

        par = self.par
        sol = self.sol

        x = np.log(par.wF_vec)
        y = np.log(sol.HF_vec/sol.HM_vec)
        A = np.vstack([np.ones(x.size),x]).T
        sol.beta0,sol.beta1 = np.linalg.lstsq(A,y,rcond=None)[0]

        return sol.beta0 , sol.beta1

    def estimate(self, question5 = False):
        """ Finds minimizing arguments for the error function 
        with respect to either alpha and sigma (question5 = False)
        or sigma and epsilon_F (question5 = True)  """

        par = self.par

        if question5 is False:

            # a. Function to minimize
            def Error_func(z):
                """ Calculate the error as a function of alpha and sigma

                Args:

                    z (list): First element should be alpha and second element should be sigma

                Returns:

                    (float): Calculated error

                """

                # i. Assign alpha and sigma
                par.alpha = z[0]
                par.sigma = z[1]

                # ii. Solve model and run regression
                self.solve_wF_vec(discrete = False, question5 = question5)
                beta0 , beta1 = self.run_regression() 
                return (0.4 - beta0) ** 2 + (-0.1 - beta1) ** 2

            # b. Bounds and guess for minimization
            bounds = ( (0+1e-8,1-1e-8), (0+1e-8,1.5))
            guess = (0.5 ,1)
    
            # c. Minimize and assign results
            solution = optimize.minimize(Error_func, guess , bounds = bounds , method = "Nelder-Mead")
            alpha_sol , sigma_sol = solution.x
    
            # d. Use results to assign beta0 and beta1
            par.alpha = alpha_sol
            par.sigma = sigma_sol
            self.solve_wF_vec(discrete = False, question5 = question5)
            beta0, beta1 = self.run_regression()
        
            return alpha_sol, sigma_sol, beta0, beta1
        
        elif question5 is True:
            # a. Function to minimize
            def Error_func(z):
                """ Calculate the error as a function of alpha and sigma

                Args:

                    z (list): First element should be alpha and second element should be sigma

                Returns:

                    (float): Calculated error

                """

                # i. Assign alpha and sigma
                par.sigma = z[0]
                par.epsilon_F= z[1]
                

                # ii. Solve model and run regression
                self.solve_wF_vec(discrete = False, question5 = question5)
                beta0 , beta1 = self.run_regression() 
                return (0.4 - beta0) ** 2 + (-0.1 - beta1) ** 2

            # b. Bounds and guess for minimization
            bounds = ( (0+1e-8,2), (0+1e-8, 10))
            guess = (1 , 2)

    
            # c. Minimize and assign results
            solution = optimize.minimize(Error_func, guess , bounds = bounds , method = "Nelder-Mead")
            sigma_sol,  epsilon_F = solution.x
    
            # d. Use results to assign beta0 and beta1
            par.sigma = sigma_sol
            par.epsilon_F = epsilon_F
            self.solve_wF_vec(discrete = False, question5 = question5)
            beta0, beta1 = self.run_regression()
            
        
            return sigma_sol, epsilon_F, beta0, beta1

    




       

        