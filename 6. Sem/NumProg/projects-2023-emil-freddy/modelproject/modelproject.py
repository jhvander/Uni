import numpy as np
from scipy import optimize
import sympy as sm
from sympy import Symbol
from sympy.solvers import solve
sm.init_printing(use_unicode=True) # for pretty printing
from IPython.display import display
import matplotlib.pyplot as plt # baseline modul
import ipywidgets as widgets
from types import SimpleNamespace

# Setting up our class/model
class Solow:
    def __init__(self,do_print=True):
           self.par = SimpleNamespace()
           self.value = SimpleNamespace()
           self.sim = SimpleNamespace()

           datamoms = self.datamoms = SimpleNamespace() # Moments in the hypothetical scenarios
           moms = self.moms = SimpleNamespace() # Moments in the theoretical model


           par = self.par
           value = self.value
           sim = self.sim

           par.k = sm.symbols('k')
           par.h = sm.symbols('h')
           par.alpha = sm.symbols('alpha')
           par.delta = sm.symbols('delta')
           par.phi =  sm.symbols('phi')
           par.sk = sm.symbols('s_k')
           par.g = sm.symbols('g')
           par.n = sm.symbols('n')
           par.sh = sm.symbols('s_h')
           par.x = sm.symbols("s_k, s_h, g, phi, n, alpha, delta")

           value.sk = 0.12
           value.sh = 0.07
           value.g = 0.02
           value.n = 0.01
           value.alpha = 0.33
           value.delta = 0.05
           value.phi = 0.33

           value.simT = 5000 #number of periods
           # Simulation zeros
           sim.y_tilde = np.zeros(value.simT)
           sim.k_tilde = np.ones(value.simT)
           sim.h_tilde = np.ones(value.simT)


           # Moments for hypothetical scenarios
           datamoms.std_y_tilde = 0.8 #2.0124
           datamoms.std_k_tilde = 0.5 #1.4673
           datamoms.std_h_tilde = 0.5 #0.7839
           datamoms.corr_k_tilde_h_tilde = 0.807
           datamoms.autocorr_y_tilde = 0.3997
           datamoms.autocorr_k_tilde = 0.3123
           datamoms.autocorr_h_tilde = 0.2359

    def plot_nullclines(self):
           ## NOT WORKING YET
           # Calculating a solution for the nullclines
           par = self.par
           value = self.value

           null_vec = np.linspace(0,10,100)
           h_null_delta_k_0 = np.empty(100)
           h_null_delta_h_0 = np.empty(100)    

           for i, k in enumerate(null_vec):
                 h_null_delta_k_0[i] = ((par.k**(1-value.alpha) * (value.n+value.g+value.delta+value.n*value.g))/(value.sk))**(1/value.phi)
                 test = optimize.root_scalar(h_null_delta_k_0[i], bracket=[1e-20, 100], method='nelder-mead')
                 h_null_delta_k_0[i] = test.root
                 
                 h_null_delta_h_0[i] = ((par.k**(-value.alpha) * (value.n+value.g+value.delta+value.n*value.g))/(value.sh))**(1/value.phi-1)
                 test = optimize.root_scalar(h_null_delta_h_0[i], bracket=[1e-20, 100], method='nelder-mead')
                 h_null_delta_h_0[i] = test.root

                 plt.plot(null_vec, h_null_delta_k_0, label = 'nullcline for physical capital')
                 plt.plot(null_vec, h_null_delta_h_0, label = 'nullcline for human capital')     
                 plt.xlabel('k') 
                 plt.ylabel('h') 
                 plt.legend()
                 plt.show()


                 # Calculating a solution for the nullclines


    def simulate(self):
           """ simulate the full model """

           np.random.seed(1574)
           par = self.par
           sim = self.sim
           value = self.value

           # b. period-by-period
           for t in range(value.simT - 1):

                 # i. lagged
                 if t == 0:
                         k_lag = sim.k_tilde[0]
                         h_lag = sim.h_tilde[0]
                         y_lag = sim.y_tilde[0]

                 else:
                         k_lag = sim.k_tilde[t]
                         h_lag = sim.h_tilde[t]
                         y_lag = sim.y_tilde[t]

                 # iii. output and inflation
            
                 sim.k_tilde[t+1] = (value.sk*k_lag**(value.alpha)*h_lag**(value.phi)+(1-value.delta)*k_lag)/((1-value.n)*(1+value.g))
                 sim.h_tilde[t+1] = (value.sh*k_lag**(value.alpha)*h_lag**(value.phi)+(1-value.delta)*k_lag)/((1+value.n)*(1+value.g))
                 sim.y_tilde[t] = sim.k_tilde[t+1]**(value.alpha)*sim.h_tilde[t+1]**(value.phi)
                 
           return sim.k_tilde, sim.h_tilde, sim.y_tilde
        


           

    def solve_analytical(self):
              
              par = self.par
              # Defining the transition equations:
              k_t1 = (par.sk*par.k**par.alpha*par.h**par.phi+(1-par.delta)*par.k)/((1+par.n)*(1+par.g))
              h_t1 = (par.sh*par.k**par.alpha*par.h**par.phi+(1-par.delta)*par.h)/((1+par.n)*(1+par.g))
              # Finding the SS - when k_(t+1) = k_t = k^*
              delta_k = k_t1 - par.k
              delta_h = h_t1 - par.h
              # Finding the equilibrium:
              equili_k = sm.Eq(delta_k,0)
              equili_h = sm.Eq(delta_h,0)
              # Creating nullclines, to find the balance between optimal capital and humancapital:
              null_k = sm.solve(equili_k,par.h)
              null_h = sm.solve(equili_h,par.h)

              # Creating an empthy space to store the results:
              return null_k, null_h, equili_k, equili_h

              

    def calc_moms(self):
        #Calculating moments in from simulation
         sim = self.sim
         moms = self.moms

         moms.std_y_tilde = np.std(sim.y_tilde)
         moms.std_k_tilde = np.std(sim.k_tilde)
         moms.std_h_tilde = np.std(sim.h_tilde)
         moms.corr_k_tilde_h_tilde = np.corrcoef(sim.k_tilde,sim.h_tilde)[0,1] 
         moms.autocorr_y_tilde = np.corrcoef(sim.y_tilde[1:],sim.y_tilde[:-1])[0,1]
         moms.autocorr_k_tilde = np.corrcoef(sim.k_tilde[1:],sim.k_tilde[:-1])[0,1]
         moms.autocorr_h_tilde = np.corrcoef(sim.h_tilde[1:],sim.h_tilde[:-1])[0,1]      

    def calc_difference_to_hypo(self,do_print=False):
        #Calculating the difference from the moments in simulation compared to the hypothetical scenarios
         moms = self.moms
         datamoms = self.datamoms

         error = 0.0 # Sum of squared differences
         for k in self.datamoms.__dict__.keys():

                 difference = datamoms.__dict__[k]-moms.__dict__[k]
                 error += difference**2

                 if do_print: print(f'{k:12s}| data = {datamoms.__dict__[k]:.4f}, model = {moms.__dict__[k]:.4f}')

         if do_print: print(f'{error = :12.8f}')

         return error
