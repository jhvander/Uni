# A. Imports
import pandas as pd

import matplotlib.pyplot as plt
plt.rcParams.update({"axes.grid":True,"grid.color":"black","grid.alpha":"0.25","grid.linestyle":"--"})
plt.rcParams.update({'font.size': 14})

#%pip install pandas-datareader
from pandas_datareader import wb

import ipywidgets as widgets

# B. Class

class DataProjectClass:
     
    def __innit__(self):
        pass
    
    def read_and_clean(self):
        """""
        Downloads data from the World Bank, fixes columns names, removes all areas for which there is missing data.

        """
        # A. Download data
        wb_CO2 = wb.download(indicator = "EN.ATM.CO2E.KT", country = "all", start = 1990, end = 2019)
        wb_POP = wb.download(indicator = "SP.POP.TOTL", country = "all", start = 1990, end = 2019)
        
        # B. Rename columns
        wb_CO2.rename(columns = {"EN.ATM.CO2E.KT": "CO2_(kt)"}, inplace=True)
        wb_POP.rename(columns = {"SP.POP.TOTL": "Population"} , inplace = True)
       
        # C. Reset indices
        wb_CO2.reset_index(inplace = True)
        wb_POP.reset_index(inplace = True)

        # D. Convert data types
        wb_CO2["country"] = wb_CO2["country"].astype('string')
        wb_CO2["year"] = wb_CO2["year"].astype(int) 
        wb_POP["country"] = wb_POP["country"].astype('string')
        wb_POP["year"] = wb_POP["year"].astype(int)

        # E. Measure CO2 in tonnes, instead of kilotonnes
        wb_CO2["CO2_(t)"] = wb_CO2["CO2_(kt)"]*1000 
        wb_CO2.drop("CO2_(kt)" , axis = 1, inplace = True)

        # F. Remove from each dataset the areas which have missing data in that dataset

        # i. Find the countries which have missing data    
        I_CO2 = wb_CO2["CO2_(t)"].isna()
        wb_CO2[I_CO2]["country"].unique()

        I_POP = wb_POP["Population"].isna()
        wb_POP[I_POP].country.unique()

        # ii. Create sets to determine what countries will be dropped and kept when merging
        drop_CO2 = set((wb_CO2[I_CO2]["country"].unique()))
        original_CO2 = set((wb_CO2["country"].unique()))
        kept_CO2 = original_CO2.symmetric_difference(drop_CO2)
    
        drop_POP = set((wb_POP[I_POP]["country"].unique()))
        original_POP = set((wb_POP["country"].unique()))
        kept_POP = original_POP.symmetric_difference(drop_POP)

        self.dropped = drop_POP.union(drop_CO2)
        self.kept = sorted(list(original_CO2.symmetric_difference(self.dropped)))

        print(f'The areas dropped from the emission dataset are: {drop_CO2}')
        print(f'The areas dropped from the population dataset are: {drop_POP}')

        # iii. Define the new datasets without missing data
        wb_CO2 = wb_CO2.loc[wb_CO2["country"].isin(kept_CO2),:]
        wb_POP = wb_POP.loc[wb_POP["country"].isin(kept_POP),:]

        self.wb_CO2 = wb_CO2.reset_index(drop = True)
        self.wb_POP = wb_POP.reset_index(drop = True)

        print("\ninfo for wb_CO2:")
        print(self.wb_CO2.info())
        print("\ninfo for wb_POP:")
        print(self.wb_POP.info())

    def explore(self):
        """ Makes an interactive plot of the datasets"""

        # A. Function to plot figure
        def plot_func(x, var = None):
            """ 
            Args:
                x (String) : Area to show plot for
                var (str) : Variables to show

            """
            # i. Create figure and subplot
            fig = plt.figure(figsize=(8, 6))
            ax = fig.add_subplot()

            # ii. Plot figure
            if var == "CO2 emissions":
                ax.plot(self.wb_CO2.loc[self.wb_CO2["country"] == x , ["year"]], self.wb_CO2.loc[self.wb_CO2["country"] == x , ["CO2_(t)"]])
                y_label = "CO2 emissions (t)"

            if var == "Population":
                ax.plot(self.wb_POP.loc[self.wb_POP["country"] == x , ["year"]], self.wb_POP.loc[self.wb_POP["country"] == x , ["Population"]])
                y_label = "Population"

            # iii. Set title and labels    
            ax.set_xlabel("Year")
            ax.set_ylabel(y_label)
            ax.set_title(x)

            # iv. Remove border
            ax.spines['top'].set_visible(False)
            ax.spines['bottom'].set_visible(False)
            ax.spines['right'].set_visible(False)
            ax.spines['left'].set_visible(False)

        # B. Create interactive plot
        widgets.interact(plot_func, 
                x = widgets.Dropdown(options = self.kept, description = "Area"),
                var = widgets.Dropdown(options = ["CO2 emissions", "Population"], description = "Variable")
               ); 

    def merge(self):
        """ Merges datasets"""

        # A. Inner Merge
        self.wb_merged = pd.merge(self.wb_CO2, self.wb_POP, how = 'inner', on = ['country','year'])

    def analysis(self):
        """ Selects regions to focus on, calculates CO2 emission per capita and indices of this variable. Finally it plots these"""

        # A. Select subset of dataset
        self.Areas = ["Africa Eastern and Southern", "Africa Western and Central", "East Asia & Pacific", "Europe & Central Asia"
                 , "Latin America & Caribbean", "Middle East & North Africa", "North America",  ]
    

        self.wb_merged = self.wb_merged.loc[self.wb_merged["country"].isin (self.Areas), :]

        # B. Construct CO2 per capita variable
        self.wb_merged["CO2_per_capita"] = self.wb_merged["CO2_(t)"] / self.wb_merged["Population"]
        
        # C. Provides summary statistics
        print(f'The selected subsample is: {self.Areas}')
        print("Summary statistics:")
        print(self.wb_merged.describe())

        # D. Perform split apply combine to make indices
        # i. Split by country
        grouped = self.wb_merged.groupby("country")["CO2_per_capita"]
        # ii. find last value
        grouped_last_value = grouped.last()
        grouped_last_value.name = "grouped_last_value"
        # iii. Combine
        self.wb_merged = self.wb_merged.set_index("country").join(grouped_last_value, how = "left")
        self.wb_merged.reset_index(inplace = True)
        # iv. Create indice column
        self.wb_merged["index_1990"] =(self.wb_merged["CO2_per_capita"] / self.wb_merged["grouped_last_value"])*100

    def plot(self):
        """ Plots the indices"""

        # A. Create figure and subplot
        fig = plt.figure(figsize=(8, 6))
        ax = fig.add_subplot()
        
        # B. Plot
        for x in self.Areas:
            ax.plot(self.wb_merged.loc[self.wb_merged["country"] == x , ["year"]] , self.wb_merged.loc[self.wb_merged["country"] == x , ["index_1990"]] , label = x, )

        # C. Set labels and title
        ax.set_xlabel("Year")
        ax.set_ylabel("index = 1990")
        ax.set_title("CO2 per capita")

        # D. Remove border
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        plt.legend(fontsize = 10)