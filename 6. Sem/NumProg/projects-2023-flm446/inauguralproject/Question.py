import numpy as np
import matplotlib.pyplot as plt
plt.rcParams.update({"axes.grid":True,"grid.color":"black","grid.alpha":"0.25","grid.linestyle":"--"})
plt.rcParams.update({'font.size': 14})

from HouseholdSpecializationModel import HouseholdSpecializationModelClass

class QuestionClass:
    """ The methods perform the necessary operations to answer the questions on the returned data from the HouseholdSpecializationModelClass  """

    def __init__(self):
        """ Initializes class"""
        
        # a. Assign class
        self.model = HouseholdSpecializationModelClass()

        # b. Vector of alpha and sigma for question 1
        self.alpha_vec = [0.25, 0.50, 0.75]
        self.sigma_vec = [0.5 , 1 , 1.5]

        # c. Matrices for solutions to question 1
        self.HF = np.empty((3,3))
        self.HM = np.empty((3,3))
    
    def question_1(self, do_plot = True):
        """ Solves the model for combinations of alpha and sigma, creates the ratio series and plots the ratios against alpha'"""

        # a. Solve model
        for i,a in enumerate(self.alpha_vec):
            self.model.par.alpha = a
            for n, s in enumerate(self.sigma_vec):
                self.model.par.sigma = s
                opt1 = self.model.solve_discrete() 
                self.HF[n,i] = opt1.HF
                self.HM[n,i] = opt1.HM
        
        # b. return parameters to baseline
        self.model.par.alpha = 0.5
        self.model.par.sigma = 1

        # c. Assign results
        HF_sigma_050 = self.HF[0,:]
        HF_sigma_100 = self.HF[1,:]
        HF_sigma_150 = self.HF[2,:]

        HM_sigma_050 = self.HM[0,:]
        HM_sigma_100 = self.HM[1,:]
        HM_sigma_150 = self.HM[2,:]

        # d. Calculate ratios
        Hratio_sigma_050 = HF_sigma_050 / HM_sigma_050
        Hratio_sigma_100 = HF_sigma_100 / HM_sigma_100
        Hratio_sigma_150 = HF_sigma_150 / HM_sigma_150

        # e. Plot results
        if do_plot is True:
            # i. Create figure
            fig = plt.figure()
            ax = fig.add_subplot(1,1,1)

            # ii. plot for sigma = 0.5
            ax.scatter(self.alpha_vec, Hratio_sigma_050, label = "$\sigma=0.5$")
            ax.plot(self.alpha_vec, Hratio_sigma_050)

            # iii. plot for sigma = 1
            ax.scatter(self.alpha_vec, Hratio_sigma_100, label = "$\sigma=1.0$")
            ax.plot(self.alpha_vec, Hratio_sigma_100)

            # iv. plot for sigma = 1.5
            ax.scatter(self.alpha_vec, Hratio_sigma_150, label = "$\sigma=1.5$")
            ax.plot(self.alpha_vec, Hratio_sigma_150)

            # v. Labels and title
            ax.set_xlabel("$\\alpha$")
            ax.set_ylabel("$\\frac{H_F}{H_M}$")
            ax.set_title("Figure 1")

            plt.legend()
            plt.show()

    def question_2_and_3(self, discrete = True, do_plot = True):
        """ Assigns results from solving the model discretely and continously for vector of wages, calculates ratios and plots the ratios
        
        Args:

            discrete (bool) : If True the ratio is calculated with the results from the discrete optimization
        
        """

        # a. Assign results and calculate ratios
        HM_vec, HF_vec  = self.model.solve_wF_vec(discrete = discrete)
        self.logWratio = np.log(self.model.par.wF_vec)
        self.logHratio = np.log(HF_vec / HM_vec)

        # b. Plot results
        if do_plot is True:
            # i. Create figure
            fig = plt.figure()
            ax = fig.add_subplot(1,1,1)

            # ii. plot ratio
            ax.scatter(self.logWratio, self.logHratio)
            ax.plot(self.logWratio, self.logHratio)

            # iii. labels and titles
            ax.set_xlabel("$ log(\\frac{W_F}{W_M})   $")
            ax.set_ylabel("$ log(\\frac{H_F}{H_M})   $")
            if discrete is True:
                ax.set_title("Figure 2")
            elif discrete is False:
                ax.set_title("Figure 3")

            plt.show()
       
    def question_4_and_5(self, question5 = False, do_plot = True):
        """ Calculates ratios based on the minimizing arguments from the estimate method and plots them 
        
        Args:

            question5 (bool) : If True the extension of the model is used throughout.
        
        """

        # a. Assign the arguments minimizing the error function and the resulting beta0 and beta1
        if question5 is False:
            alpha, sigma , _beta0 , _beta1 = self.model.estimate(question5 = question5)

            # i. Solve model with the minimizing values of alpha and sigma and calculate ratio
            self.model.par.alpha = alpha
            self.model.par.sigma = sigma
            HM_vec , HF_vec = self.model.solve_wF_vec(question5 = question5)
            logHratio = np.log(HF_vec / HM_vec)

            # ii. Return parameters to baseline
            self.model.par.alpha = 0.5
            self.model.par.simga = 1

        if question5 is True:
            sigma , epsilon_F , _beta0, _beta1 = self.model.estimate(question5 = question5)

            # i. Solve model with the minimizing values of sigma and epsilon_F and calculate ratio
            self.model.par.sigma = sigma
            self.model.par.epsilon_F = epsilon_F
            HM_vec , HF_vec = self.model.solve_wF_vec(question5 = question5)
            logHratio = np.log(HF_vec / HM_vec)
        
        # b. Ratio from data
        logHratio_data = 0.4 - 0.1 * np.log(self.model.par.wF_vec)
    
        # c. plot ratios
        if do_plot is True:

            # i. Create figure
            fig = plt.figure()
            ax = fig.add_subplot(1,1,1)

            # ii. plot ratios
            ax.scatter(self.logWratio, logHratio_data, alpha = 0.2, color = "red", label = "Data")
            ax.plot(self.logWratio, logHratio_data, alpha = 0.2, color = "red")
            ax.scatter(self.logWratio, logHratio, alpha = 0.2, color = "blue" , label = "Calculated")
            ax.plot(self.logWratio, logHratio, alpha = 0.2 , color = "blue")

            # iii. Labels and titles
            ax.set_xlabel("$ log(\\frac{W_F}{W_M})   $")
            ax.set_ylabel("$ log(\\frac{H_F}{H_M})   $")
            if question5 is False:
                ax.set_title("Figure 4")
            elif question5 is True:
                ax.set_title("Figure 5")
            plt.legend()
            plt.show()
    
        

        
    

