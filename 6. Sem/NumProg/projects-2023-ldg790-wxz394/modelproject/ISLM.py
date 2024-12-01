import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint


class ODESolver:
    def __init__(self, f): # Defines a constructor method for the ODESolver class that takes in a function f as an argument.

        self.f = lambda u, t: np.asarray(f(u, t), float)
        #Defines an instance variable self.f which is a new function created by 
        # wrapping the user-defined function f to convert list or tuple inputs to a numpy array
    def set_initial_condition(self, U0): #Defines a method named set_initial_condition that takes in an initial condition U0 as an argument.
        if isinstance(U0, (float,int)):  # Checks if the initial condition is a scalar value (float or int).  
            self.neq = 1                   
            self.U0 = float(U0)
        else: # system of ODEs
            U0 = np.asarray(U0)
            self.neq = U0.size # no of equations
            self.U0 = U0
            
    def solve(self, time_points):
        self.t = np.asarray(time_points) #Converts time_points to a numpy array and sets 
        #it as an instance variable self.t. The length of self.t is stored in N.

        N = len(self.t)

        if self.neq == 1: # scalar ODEs
            self.u = np.zeros(N)
        
        else: # systems of ODEs
            self.u = np.zeros((N,self.neq))
            
        # Assumes that the initial condition self.U0 corresponds to the first time point 
        self.u[0] = self.U0
        
        # Iterates over each time point from self.t[1] to self.t[N-1]
        #  and computes the corresponding ODE solution by calling the advance() method.
        for n in range(N-1):
            self.n = n
            self.u[n+1] = self.advance()
        return self.u, self.t
    

class RungeKutta4(ODESolver): # Definine the RungeKutta4 class that inherits from the ODESolver class.
    def advance(self):
        u, f, n, t = self.u, self.f, self.n, self.t #Unpack the current state, ODE function, current time step, and time array from the self attribute.
        dt = t[n+1] - t[n] # Calculate the size of the time step.
        dt2 = dt/2.0 # Calculate the midpoint of the time step.
        k1 = f(u[n], t) # Calculate the four Runge-Kutta steps.
        k2 = f(u[n] + dt2*k1, t[n] + dt2)
        k3 = f(u[n] + dt2*k2, t[n] + dt2)
        k4 = f(u[n] + dt*k3, t[n] + dt)
        unew = u[n] + (dt/6.0)*(k1 + 2*k2 + 2*k3 + k4) # Calculate the new state.
        return unew

#Define the ForwardEuler class that inherits from the ODESolver class.
class ForwardEuler(ODESolver):
    def advance(self):
        u, f, n, t = self.u, self.f, self.n, self.t # Unpack the current state, ODE function, current time step, and time array from the self attribute.
        dt = t[n+1] - t[n] # Calculate the size of the time step.
        unew = u[n] + dt*f(u[n], t[n]) # Calculate the new state.
        return unew

