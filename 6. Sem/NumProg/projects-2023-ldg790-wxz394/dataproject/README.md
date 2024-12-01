# Data analysis project
This project is written by ldg790 & wxz394 belonging to exercise class 3.

Our project is titled **Automated trading strategy** and it investigates the feasibility of predicting companies' future stock prices and achieving an abnormal excess return. The project will focus on companies in the Dow Jones index from the year 2013 to 2019. We will use an API from financial modelling prep, which allows us to access key financial data for all the companies, with a primary focus on P/S, P/B, P/E, DCF and WACC. To evaluate the model, the project compares its predictions against actual market outcomes. Here we determine a buy or sell recommendation for the year 2014-2019 for the ratios and only recommend for the year 2019 with the DCF and WACC variables. The project will compare predictions against actual outcomes for all the different financial variables. 

The API is free to use after creating an account but has a limit of 250 requests a day. Therefore, to access all 30 companies in the Dow Jones index, one must wait 24 hours to get the data for the next companies or create a second account. We used two accounts to get the data from the first 25 companies and then the last 5 companies. 

We saved the data in a CSV file to avoid having to wait 24 hours to get the data. Meaning, final_merger.csv contains all the financial variables and the profit_difference:more_years.csv and contains the profit difference for the years 2014-2019. !!!! DISCLAIMER: Running the code section optimally in "Get financial data from financialmodelingprep.com" requires two API keys. Furthermore, running the code will automatically save your results as a CSV file. Be careful not to overwrite the existing data.

Start from the section "Define the datasets and load csv files", if you do not want to compute the data over again, it is time consuming.

The **results** of the project can be seen by running [dataproject.ipynb](dataproject.ipynb).


**Dependencies:** Apart from a standard Anaconda Python 3 installation, the project requires the following installations:

``pip install ssl``
``pip install sklearn.linear_model``
``pip install datetime``
``pip install pandas_datareader.data``
``pip install os``
