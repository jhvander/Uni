#Pakker
import numpy as np
import scipy as scipy
from sklearn import neural_network, linear_model, ensemble
import numdifftools as nd

def bs_put(start_price, Rf, t_year, strike, sigma):
    d1 = 1/(sigma*np.sqrt(t_year))*(np.log(start_price/strike)+(Rf + 0.5*sigma**2)*t_year)
    d2 = d1 - sigma*np.sqrt(t_year)
    N1 = scipy.stats.norm.cdf(-d1)
    N2 = scipy.stats.norm.cdf(-d2)
    price = N2*strike*np.exp(-Rf*t_year) - N1*start_price
    return price

def bs_put_minimum(start_price, start_price2, Rf, t_year, strike, sigma, sigma2):
    d11 = 1/(sigma*np.sqrt(t_year))*(np.log(start_price/strike)+(Rf + 0.5*sigma**2)*t_year)
    d21 = d11 - sigma*np.sqrt(t_year)
    d12 = 1/(sigma2*np.sqrt(t_year))*(np.log(start_price/strike)+(Rf + 0.5*sigma2**2)*t_year)
    d22 = d12 - sigma2*np.sqrt(t_year)
    var = sigma**2 + sigma2**2
    d2_1 = 1/np.sqrt(var*t_year)*(np.log(start_price2/start_price)-var/2*t_year)
    d2_2 = 1/np.sqrt(var*t_year)*(np.log(start_price/start_price2)-var/2*t_year)
    rho1 = sigma/np.sqrt(sigma**2+sigma2**2)
    rho2 = sigma2/np.sqrt(sigma**2+sigma2**2)
    cov1 = np.array([ [1, -rho1],[-rho1,1]])
    cov2 = np.array([ [1, -rho2],[-rho2,1]])
    cov3 = np.array([[1,0],[0,1]])
    call_minimum = 0
    call_minimum += start_price*scipy.stats.multivariate_normal.cdf(x = np.array([d2_1,d11]), cov=cov1)
    call_minimum += start_price2*scipy.stats.multivariate_normal.cdf(x = np.array([d2_2,d12]), cov=cov2)
    call_minimum -= strike*np.exp(-Rf*t_year)*(scipy.stats.multivariate_normal.cdf(x = np.array([d21,d22]), cov=cov3))
    call_minimum_0 = 0
    call_minimum_0 += start_price*scipy.stats.multivariate_normal.cdf(x = d2_1)
    call_minimum_0 += start_price2*scipy.stats.multivariate_normal.cdf(x = d2_2)
    put_minimum = call_minimum - call_minimum_0 + strike*np.exp(-Rf*t_year)#put call parity
    return put_minimum

def european_put_price(paths, Rf, strike, t_year):
    discount_factor = np.exp(-Rf)**t_year
    price = np.mean(discount_factor*np.maximum(strike - paths[:,-1], 0))
    return price

def european_put_minimum_price(paths, paths2, Rf, strike, t_year):
    discount_factor = np.exp(-Rf*t_year)
    price = np.mean(discount_factor*np.maximum(strike - np.minimum(paths[:,-1],paths2[:,-1]), 0))
    return price

def lsm_put(paths, Rf, strike, t_year, stop=False):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
    if stop:
        stopping_rule = [0]
    for i in range(periods-2,0,-1):
        temp_cash_flow = np.maximum(strike-paths[:,i],0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X_matrix = np.column_stack((paths[:,i],paths[:,i]**2))
            regress = linear_model.LinearRegression()
            regress.fit(X_matrix[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(regress)
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def lsm_put_delta(paths, Rf, strike, t_year, stopping_rule):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta = np.zeros((4,periods-1))
    cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
    for i in range(periods-2,0,-1):
        #delta_regress = np.polyfit(paths[:,i],cash_flow,8)
        #X_matrix = np.column_stack((paths[:,i],paths[:,i]**2,paths[:,i]**3,paths[:,i]**4,paths[:,i]**5,paths[:,i]**6,paths[:,i]**7,paths[:,i]**8,paths[:,i]**9))
        X_matrix = np.column_stack((paths[:,i],paths[:,i]**2,paths[:,i]**3,paths[:,i]**4))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        #delta[:,i] = [4*delta_regress[0],3*delta_regress[1],2*delta_regress[2],delta_regress[3]]
        #delta[:,i] = [8*delta_regress[0],7*delta_regress[1],6*delta_regress[2],5*delta_regress[3],4*delta_regress[4],3*delta_regress[5],2*delta_regress[6],delta_regress[7]]
        #delta[:,i] = [9*coef[8],8*coef[7],7*coef[6],6*coef[5],5*coef[4],4*coef[3],3*coef[2],2*coef[1],coef[0]]
        delta[:,i] = [4*coef[3],3*coef[2],2*coef[1],coef[0]]
        temp_cash_flow = np.maximum(strike-paths[:,i],0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X_matrix = np.column_stack((paths[:,i],paths[:,i]**2))
            regress = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    #delta_regress = np.polyfit(paths[:,0],cash_flow,8)
    # delta[:,0] = [4*delta_regress[0],3*delta_regress[1],2*delta_regress[2],delta_regress[3]]
    #delta[:,0] = [8*delta_regress[0],7*delta_regress[1],6*delta_regress[2],5*delta_regress[3],4*delta_regress[4],3*delta_regress[5],2*delta_regress[6],delta_regress[7]]
    #X_matrix = np.column_stack((paths[:,0],paths[:,0]**2,paths[:,0]**3,paths[:,0]**4,paths[:,0]**5,paths[:,0]**6,paths[:,0]**7,paths[:,0]**8,paths[:,0]**9))
    X_matrix = np.column_stack((paths[:,i],paths[:,i]**2,paths[:,i]**3,paths[:,i]**4))
    delta_regress = linear_model.LinearRegression()
    delta_regress.fit(X_matrix,cash_flow)
    coef = delta_regress.coef_
    #delta[:,0] = [9*coef[8],8*coef[7],7*coef[6],6*coef[5],5*coef[4],4*coef[3],3*coef[2],2*coef[1],coef[0]]
    delta[:,0] = [4*coef[3],3*coef[2],2*coef[1],coef[0]]
    price = np.mean(cash_flow)
    return price, delta

def lsm_put_minimum(paths1, paths2, Rf, strike, t_year, stop=False):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    if stop:
        stopping_rule = [0]
    cash_flow = np.maximum(strike-np.minimum(S1,S2),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
            regress = linear_model.LinearRegression()
            regress.fit(X_matrix[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(regress)
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def lsm_put_minimum_delta(paths1, paths2, Rf, strike, t_year, stopping_rule):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta1 = np.zeros((6,periods-1))
    delta2 = np.zeros((6,periods-1))
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    cash_flow = np.maximum(strike-np.minimum(S1,S2),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        delta1[:,i] = [coef[0],2*coef[1],3*coef[2],coef[6],2*coef[7],coef[8]]
        delta2[:,i] = [coef[3],2*coef[4],3*coef[5],coef[6],coef[7],2*coef[8]]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            regress = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    S1 = paths1[:,0]
    S2 = paths2[:,0]
    X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
    delta_regress = linear_model.LinearRegression()
    delta_regress.fit(X_matrix,cash_flow)
    coef = delta_regress.coef_
    delta1[:,0] = [coef[0],2*coef[1],3*coef[2],coef[6],2*coef[7],coef[8]]
    delta2[:,0] = [coef[3],2*coef[4],3*coef[5],coef[6],coef[7],2*coef[8]]
    price = np.mean(cash_flow)
    return price, delta1,delta2

def lsm_put_minimum_5(paths1, paths2, paths3, paths4, paths5, Rf, strike, t_year, stop=False):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    S3 = paths3[:,-1]
    S4 = paths4[:,-1]
    S5 = paths5[:,-1]
    if stop:
        stopping_rule = [0]
    cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        S3 = paths3[:,i]
        S4 = paths4[:,i]
        S5 = paths5[:,i]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
                S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
            regress = linear_model.LinearRegression()
            regress.fit(X_matrix[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(regress)
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def lsm_put_minimum_delta_5(paths1, paths2, paths3, paths4, paths5, Rf, strike, t_year, stopping_rule):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta1 = np.zeros((6,periods-1))
    delta2 = np.zeros((6,periods-1))
    delta3 = np.zeros((6,periods-1))
    delta4 = np.zeros((6,periods-1))
    delta5 = np.zeros((6,periods-1))
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    S3 = paths3[:,-1]
    S4 = paths4[:,-1]
    S5 = paths5[:,-1]
    cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        S3 = paths3[:,i]
        S4 = paths4[:,i]
        S5 = paths5[:,i]
        X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
            S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        delta1[:,i] = [coef[0],2*coef[1],coef[10],coef[11],coef[12],coef[13]]
        delta2[:,i] = [coef[2],2*coef[3],coef[10],coef[14],coef[15],coef[16]]
        delta3[:,i] = [coef[4],2*coef[5],coef[11],coef[14],coef[17],coef[18]]
        delta4[:,i] = [coef[6],2*coef[7],coef[12],coef[15],coef[17],coef[19]]
        delta5[:,i] = [coef[8],2*coef[9],coef[13],coef[16],coef[18],coef[19]]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            regress = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = regress.predict(X_matrix)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    S1 = paths1[:,0]
    S2 = paths2[:,0]
    S3 = paths3[:,0]
    S4 = paths4[:,0]
    S5 = paths5[:,0]
    X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
        S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
    delta_regress = linear_model.LinearRegression()
    delta_regress.fit(X_matrix,cash_flow)
    coef = delta_regress.coef_
    delta1[:,0] = [coef[0],2*coef[1],coef[10],coef[11],coef[12],coef[13]]
    delta2[:,0] = [coef[2],2*coef[3],coef[10],coef[14],coef[15],coef[16]]
    delta3[:,0] = [coef[4],2*coef[5],coef[11],coef[14],coef[17],coef[18]]
    delta4[:,0] = [coef[6],2*coef[7],coef[12],coef[15],coef[17],coef[19]]
    delta5[:,0] = [coef[8],2*coef[9],coef[13],coef[16],coef[18],coef[19]]
    price = np.mean(cash_flow)
    return price, delta1, delta2, delta3, delta4, delta5

def mlp1_put(paths, Rf, strike, t_year, stop=False):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
    if stop:
        stopping_rule = [0]
    for i in range(periods-2,0,-1):
        print(i)
        temp_cash_flow = np.maximum(strike-paths[:,i],0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.atleast_2d(paths[:,i]).T
            model = neural_network.MLPRegressor((40,40),activation="relu",solver="adam",batch_size=512,learning_rate ="adaptive",learning_rate_init=0.001)
            model.fit(X[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(model)
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def mlp1_put_delta(paths, Rf, strike, t_year, stopping_rule):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta = np.zeros((4,periods-1))
    cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
    for i in range(periods-2,0,-1):
        #delta_regress = np.polyfit(paths[:,i],cash_flow,8)
        #X_matrix = np.column_stack((paths[:,i],paths[:,i]**2,paths[:,i]**3,paths[:,i]**4,paths[:,i]**5,paths[:,i]**6,paths[:,i]**7,paths[:,i]**8))
        X_matrix = np.column_stack((paths[:,i],paths[:,i]**2,paths[:,i]**3,paths[:,i]**4))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        #delta[:,i] = [4*delta_regress[0],3*delta_regress[1],2*delta_regress[2],delta_regress[3]]
        #delta[:,i] = [8*delta_regress[0],7*delta_regress[1],6*delta_regress[2],5*delta_regress[3],4*delta_regress[4],3*delta_regress[5],2*delta_regress[6],delta_regress[7]]
        delta[:,i] = [8*coef[7],7*coef[6],6*coef[5],5*coef[4],4*coef[3],3*coef[2],2*coef[1],coef[0]]
        delta[:,i] = [4*coef[3],3*coef[2],2*coef[1],coef[0]]
        temp_cash_flow = np.maximum(strike-paths[:,i],0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.atleast_2d(paths[:,i]).T
            model = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
        #X_matrix = np.column_stack((paths[:,0],paths[:,0]**2,paths[:,0]**3,paths[:,0]**4,paths[:,0]**5,paths[:,0]**6,paths[:,0]**7,paths[:,0]**8))
        X_matrix = np.column_stack((paths[:,0],paths[:,0]**2,paths[:,0]**3,paths[:,0]**4))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        #delta[:,0] = [8*coef[7],7*coef[6],6*coef[5],5*coef[4],4*coef[3],3*coef[2],2*coef[1],coef[0]]
        delta[:,0] = [4*coef[3],3*coef[2],2*coef[1],coef[0]]
    price = np.mean(cash_flow)
    return price, delta

def mlp1_put_minimum(paths,paths2, Rf, strike, t_year, stop=False):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    cash_flow = np.maximum(strike-np.minimum(paths[:,-1],paths2[:,-1]),0)*discount_factor
    if stop:
        stopping_rule = [0]
    for i in range(periods-2,0,-1):
        print(i)
        temp_cash_flow = np.maximum(strike-np.minimum(paths[:,i],paths2[:,i]),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.column_stack((paths[:,i],paths2[:,i]))
            model = neural_network.MLPRegressor((100),activation="relu",solver="adam",batch_size=512,learning_rate = "adaptive",learning_rate_init=0.001)
            model.fit(X[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(model)
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def mlp1_put_minimum_delta(paths1, paths2, Rf, strike, t_year, stopping_rule):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta1 = np.zeros((6,periods-1))
    delta2 = np.zeros((6,periods-1))
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    cash_flow = np.maximum(strike-np.minimum(S1,S2),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        delta1[:,i] = [coef[0],2*coef[1],3*coef[2],coef[6],2*coef[7],coef[8]]
        delta2[:,i] = [coef[3],2*coef[4],3*coef[5],coef[6],coef[7],2*coef[8]]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.column_stack((S1,S2))
            model = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    S1 = paths1[:,0]
    S2 = paths2[:,0]
    X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
    delta_regress = linear_model.LinearRegression()
    delta_regress.fit(X_matrix,cash_flow)
    coef = delta_regress.coef_
    delta1[:,0] = [coef[0],2*coef[1],3*coef[2],coef[6],2*coef[7],coef[8]]
    delta2[:,0] = [coef[3],2*coef[4],3*coef[5],coef[6],coef[7],2*coef[8]]
    price = np.mean(cash_flow)
    return price,delta1,delta2

def mlp1_put_minimum_5(paths,paths2, paths3, paths4, paths5, Rf, strike, t_year, stop=False):
    n,periods = paths.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    cash_flow = np.maximum(strike-np.minimum(paths[:,-1],paths2[:,-1],np.minimum(paths3[:,-1],paths4[:,-1],paths5[:,-1])),0)*discount_factor
    if stop:
        stopping_rule = [0]
    for i in range(periods-2,0,-1):
        print(i)
        temp_cash_flow = np.maximum(strike-np.minimum(paths[:,i],paths2[:,i],np.minimum(paths3[:,i],paths4[:,i],paths5[:,i])),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.column_stack((paths[:,i],paths2[:,i],paths3[:,i],paths4[:,i],paths5[:,i]))
            model = neural_network.MLPRegressor((100),activation="relu",solver="adam",batch_size=512,learning_rate = "adaptive",learning_rate_init=0.001)
            model.fit(X[b00l,:],cash_flow[b00l])
        else:
            if stop:
                stopping_rule.append(0)
            cash_flow *= discount_factor
            continue
        if stop:
            stopping_rule.append(model)
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    price = np.mean(cash_flow)
    if stop:
        stopping_rule.append(0)
        stopping_rule.reverse()
        return price, stopping_rule
    else:
        return price

def mlp1_put_minimum_delta_5(paths1, paths2, paths3, paths4, paths5, Rf, strike, t_year, stopping_rule):
    n,periods = paths1.shape
    dt = t_year/(periods-1)
    discount_factor = np.exp(-dt*Rf)#Periodisk diskonteringsfaktor
    delta1 = np.zeros((6,periods-1))
    delta2 = np.zeros((6,periods-1))
    delta3 = np.zeros((6,periods-1))
    delta4 = np.zeros((6,periods-1))
    delta5 = np.zeros((6,periods-1))
    S1 = paths1[:,-1]
    S2 = paths2[:,-1]
    S3 = paths3[:,-1]
    S4 = paths4[:,-1]
    S5 = paths5[:,-1]
    cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)*discount_factor
    for i in range(periods-2,0,-1):
        S1 = paths1[:,i]
        S2 = paths2[:,i]
        S3 = paths3[:,i]
        S4 = paths4[:,i]
        S5 = paths5[:,i]
        X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
            S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
        delta_regress = linear_model.LinearRegression()
        delta_regress.fit(X_matrix,cash_flow)
        coef = delta_regress.coef_
        delta1[:,i] = [coef[0],2*coef[1],coef[10],coef[11],coef[12],coef[13]]
        delta2[:,i] = [coef[2],2*coef[3],coef[10],coef[14],coef[15],coef[16]]
        delta3[:,i] = [coef[4],2*coef[5],coef[11],coef[14],coef[17],coef[18]]
        delta4[:,i] = [coef[6],2*coef[7],coef[12],coef[15],coef[17],coef[19]]
        delta5[:,i] = [coef[8],2*coef[9],coef[13],coef[16],coef[18],coef[19]]
        temp_cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)
        b00l = temp_cash_flow > 0
        if np.any(b00l):
            X = np.column_stack((S1,S2,S3,S4,S5))
            model = stopping_rule[i]
        else:
            cash_flow *= discount_factor
            continue
        y = model.predict(X)
        cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
        cash_flow *= discount_factor
    S1 = paths1[:,0]
    S2 = paths2[:,0]
    S3 = paths3[:,0]
    S4 = paths4[:,0]
    S5 = paths5[:,0]
    X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
        S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
    delta_regress = linear_model.LinearRegression()
    delta_regress.fit(X_matrix,cash_flow)
    coef = delta_regress.coef_
    delta1[:,0] = [coef[0],2*coef[1],coef[10],coef[11],coef[12],coef[13]]
    delta2[:,0] = [coef[2],2*coef[3],coef[10],coef[14],coef[15],coef[16]]
    delta3[:,0] = [coef[4],2*coef[5],coef[11],coef[14],coef[17],coef[18]]
    delta4[:,0] = [coef[6],2*coef[7],coef[12],coef[15],coef[17],coef[19]]
    delta5[:,0] = [coef[8],2*coef[9],coef[13],coef[16],coef[18],coef[19]]
    price = np.mean(cash_flow)
    return price, delta1, delta2, delta3, delta4, delta5

def monte_carlo_simulation(start_price,Rf,sigma,n,t_year,dt=1/50):
    periods = int(1/dt*t_year) + 1
    paths = np.empty([n,periods])
    if isinstance(start_price,int):
        paths[:,0] = np.ones(n)*start_price
    else:
        paths[:,0] = start_price
    paths[:n//2,1:] = np.random.normal(0,np.sqrt(dt),[n//2,periods-1])
    paths[n//2:,1:] = np.cumprod(np.exp((Rf-1/2*sigma**2)*dt-sigma*paths[:n//2,1:]),axis=1)*np.atleast_2d(paths[n//2:,0]).T
    paths[:n//2,1:] = np.cumprod(np.exp((Rf-1/2*sigma**2)*dt+sigma*paths[:n//2,1:]),axis=1)*np.atleast_2d(paths[:n//2,0]).T
    return paths

def binomial_put(start_price,Rf,sigma,n,t_year,strike,continent="eu",et=-1):
    if et == -1:
        temp = 1
    else:
        temp = n/(t_year*et)
    dt = t_year/n
    discount_factor = np.exp(-Rf*dt)
    u = np.exp(sigma*np.sqrt(dt))
    d = 1/u
    q = (np.exp(Rf*dt)-d)/(u-d)
    index = np.arange(-n,n+1,2)
    price = np.maximum(strike-start_price*u**index,0)
    for j in range(n-1,-1,-1):
        index = np.arange(-j,j+1,2)
        exercise_price = np.maximum(strike-start_price*u**index,0)
        continuation_price = q*price[1:j+2]*discount_factor + (1-q)*price[0:j+1]*discount_factor
        if continent == "eu":
            price[:j+1] = continuation_price
        elif continent == "am" and j%temp == 0:
            price[:j+1] = np.maximum(exercise_price,continuation_price)
        else:
            price[:j+1] = continuation_price
    return price[0]

def binomial_put_minimum(start_price1,start_price2,Rf,sigma1,sigma2,n,t_year,strike,continent="eu"):
    dt = t_year/n
    discount_factor = np.exp(-Rf*dt)
    u1 = np.exp(sigma1*np.sqrt(dt))
    d1 = 1/u1
    u2 = np.exp(sigma2*np.sqrt(dt))
    d2 = 1/u2
    q1 = (np.exp(Rf*dt)-d1)/(u1-d1)
    q2 = (np.exp(Rf*dt)-d2)/(u2-d2)
    q_uu = q1*q2
    q_ud = q1*(1-q2)
    q_du = (1-q1)*q2
    q_dd = (1-q1)*(1-q2)
    #Peters parametre
    # rho = 0.5
    # mu1 = Rf-1/2*sigma1**2
    # mu2 = Rf-1/2*sigma2**2
    # q_uu = 1/4*(1+rho+np.sqrt(dt)*(mu1/sigma1+mu2/sigma2))
    # q_ud = 1/4*(1-rho+np.sqrt(dt)*(mu1/sigma1-mu2/sigma2))
    # q_du = 1/4*(1-rho+np.sqrt(dt)*(-mu1/sigma1+mu2/sigma2))
    # q_dd = 1/4*(1+rho+np.sqrt(dt)*(-mu1/sigma1-mu2/sigma2))
    S = np.full((n+1,n+1),np.arange(-n,n+1,2)).T
    S = np.minimum(start_price1*u1**S,start_price2*u2**(S.T))
    price = np.maximum(strike-S,0)
    for j in range(n-1,-1,-1):
        continuation_price = q_uu*price[1:j+2,1:j+2]*discount_factor + q_ud*price[1:j+2,0:j+1]*discount_factor
        continuation_price += q_du*price[0:j+1,1:j+2]*discount_factor + q_dd*price[0:j+1,0:j+1]*discount_factor
        if continent == "eu":
            price[:j+1,:j+1] = continuation_price
        else:
            S = np.full((j+1,j+1),np.arange(-j,j+1,2)).T
            S = np.minimum(start_price1*u1**S,start_price2*u2**(S.T))
            exercise_price = np.maximum(strike-S,0)
            price[:j+1,:j+1] = np.maximum(exercise_price,continuation_price)
    return price[0,0]

def put_price(start_price,Rf,sigma,n,strike,t_year,model="lsm",et=50,et_dt_forhold=1):
    dt = 1/(et*et_dt_forhold)
    if isinstance(start_price,int):
        paths = monte_carlo_simulation(start_price,Rf,sigma,n,t_year,dt)
        paths = paths[:,::et_dt_forhold]
        if model == "lsm":
            price = lsm_put(paths,Rf,strike,t_year)
        else:
            price = mlp1_put(paths,Rf,strike,t_year)
    elif len(start_price)==2:
        paths1 = monte_carlo_simulation(start_price[0],Rf,sigma[0],n,t_year,dt)
        paths2 = monte_carlo_simulation(start_price[1],Rf,sigma[1],n,t_year,dt)
        paths1 = paths1[:,::et_dt_forhold]
        paths2 = paths2[:,::et_dt_forhold]
        if model == "lsm":
            price = lsm_put_minimum(paths1,paths2,Rf,strike,t_year)
        else:
            price = mlp1_put_minimum(paths1,paths2,Rf,strike,t_year)
    else:
        paths1 = monte_carlo_simulation(start_price[0],Rf,sigma[0],n,t_year,dt)[:,::et_dt_forhold]
        paths2 = monte_carlo_simulation(start_price[1],Rf,sigma[1],n,t_year,dt)[:,::et_dt_forhold]
        paths3 = monte_carlo_simulation(start_price[2],Rf,sigma[2],n,t_year,dt)[:,::et_dt_forhold]
        paths4 = monte_carlo_simulation(start_price[3],Rf,sigma[3],n,t_year,dt)[:,::et_dt_forhold]
        paths5 = monte_carlo_simulation(start_price[4],Rf,sigma[4],n,t_year,dt)[:,::et_dt_forhold]
        if model == "lsm":
            price = lsm_put_minimum_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year)
        else:
            price = mlp1_put_minimum_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year)
    return price

def hedging_experiment(start_price,test_paths,Rf,sigma,n,strike,t_year,model="lsm",et=50,et_dt_forhold=1):
    dt = 1/(et*et_dt_forhold)
    ex_periods = int(et*t_year)
    discount_factor = np.exp(-Rf*1/et)
    if isinstance(start_price,int):
        paths = monte_carlo_simulation(start_price,Rf,sigma,n,t_year,dt)
        paths = paths[:,::et_dt_forhold]
        if model == "lsm":
            price,stopping_rule = lsm_put(paths,Rf,strike,t_year,True)
            start_price_list = np.random.uniform(start_price*0.9,start_price*1.1,n)
            paths = monte_carlo_simulation(start_price_list,Rf,sigma,n,t_year,dt)
            paths = paths[:,::et_dt_forhold]
            _,delta_list = lsm_put_delta(paths,Rf,strike,t_year,stopping_rule)
        else:
            price,stopping_rule = mlp1_put(paths,Rf,strike,t_year,True)
            start_price_list = np.random.uniform(start_price*0.9,start_price*1.1,n)
            paths = monte_carlo_simulation(start_price_list,Rf,sigma,n,t_year,dt)
            paths = paths[:,::et_dt_forhold]
            _,delta_list = mlp1_put_delta(paths,Rf,strike,t_year,stopping_rule)
        paths = test_paths[:,::et_dt_forhold]
        ex_tidspunkt = np.ones(n)*ex_periods
        cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
        for i in range(ex_periods-1,0,-1):#payoff for hver sti
            temp_cash_flow = np.maximum(strike-paths[:,i],0)
            b00l = temp_cash_flow > 0
            if np.any(b00l):
                if model == "lsm":
                    X_matrix = np.column_stack((paths[:,i],paths[:,i]**2))
                else:
                    X_matrix = np.atleast_2d(paths[:,i]).T
                regress = stopping_rule[i]
            else:
                cash_flow *= discount_factor
                continue
            y = regress.predict(X_matrix)
            cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
            ex_tidspunkt[np.logical_and(b00l,temp_cash_flow>=y)] = i
            cash_flow *= discount_factor
        delta = delta_list[0,0]*paths[:,0]**3+delta_list[1,0]*paths[:,0]**2+delta_list[2,0]*paths[:,0]+delta_list[3,0]
        #delta = delta_list[0,0]*paths[:,0]**8+delta_list[1,0]*paths[:,0]**7+delta_list[2,0]*paths[:,0]**6+delta_list[3,0]*paths[:,0]**5+delta_list[4,0]*paths[:,0]**4+delta_list[5,0]*paths[:,0]**3+delta_list[6,0]*paths[:,0]**2+delta_list[7,0]*paths[:,0]+delta_list[8,0]
        B = price-delta*paths[:,0]
        V_final = np.zeros(n)
        for i in range(1,ex_periods+1):#hedge portfølje for hver sti
            delta = delta_list[0,i-1]*paths[:,i-1]**3+delta_list[1,i-1]*paths[:,i-1]**2+delta_list[2,i-1]*paths[:,i-1]+delta_list[3,i-1]
            #delta = delta_list[0,i-1]*paths[:,i-1]**8+delta_list[1,i-1]*paths[:,i-1]**7+delta_list[2,i-1]*paths[:,i-1]**6+delta_list[3,i-1]*paths[:,i-1]**5+delta_list[4,i-1]*paths[:,i-1]**4+delta_list[5,i-1]*paths[:,i-1]**3+delta_list[6,i-1]*paths[:,i-1]**2+delta_list[7,i-1]*paths[:,i-1]+delta_list[8,i-1]
            V = delta*paths[:,i]+B*1/discount_factor
            if i != ex_periods:
                delta = delta_list[0,i]*paths[:,i]**3+delta_list[1,i]*paths[:,i]**2+delta_list[2,i]*paths[:,i]+delta_list[3,i]
                #delta = delta_list[0,i]*paths[:,i]**8+delta_list[1,i]*paths[:,i]**7+delta_list[2,i]*paths[:,i]**6+delta_list[3,i]*paths[:,i]**5+delta_list[4,i]*paths[:,i]**4+delta_list[5,i]*paths[:,i]**3+delta_list[6,i]*paths[:,i]**2+delta_list[7,i]*paths[:,i]+delta_list[8,i]
                B = V - delta*paths[:,i]
            b00l = ex_tidspunkt == i
            V_final[b00l] = V[b00l]*discount_factor**i
    elif len(start_price) == 2:
        paths = monte_carlo_simulation(start_price[0],Rf,sigma[0],n,t_year,dt)
        paths = paths[:,::et_dt_forhold]
        paths2 = monte_carlo_simulation(start_price[1],Rf,sigma[1],n,t_year,dt)
        paths2 = paths2[:,::et_dt_forhold]
        if model == "lsm":
            price,stopping_rule = lsm_put_minimum(paths,paths2,Rf,strike,t_year,True)
            start_price_list = np.random.uniform(start_price[0]*0.9,start_price[0]*1.1,n)
            start_price_list2 = np.random.uniform(start_price[1]*0.9,start_price[1]*1.1,n)
            paths = monte_carlo_simulation(start_price_list,Rf,sigma[0],n,t_year,dt)
            paths = paths[:,::et_dt_forhold]
            paths2 = monte_carlo_simulation(start_price_list2,Rf,sigma[1],n,t_year,dt)
            paths2 = paths2[:,::et_dt_forhold]
            _,delta_list,delta_list2 = lsm_put_minimum_delta(paths,paths2,Rf,strike,t_year,stopping_rule)
        else:
            price,stopping_rule = mlp1_put_minimum(paths,paths2,Rf,strike,t_year,True)
            start_price_list = np.random.uniform(start_price[0]*0.9,start_price[0]*1.1,n)
            start_price_list2 = np.random.uniform(start_price[1]*0.9,start_price[1]*1.1,n)
            paths = monte_carlo_simulation(start_price_list,Rf,sigma[0],n,t_year,dt)
            paths2 = monte_carlo_simulation(start_price_list2,Rf,sigma[1],n,t_year,dt)
            paths = paths[:,::et_dt_forhold]
            paths2 = paths2[:,::et_dt_forhold]
            _,delta_list,delta_list2 = mlp1_put_minimum_delta(paths,paths2,Rf,strike,t_year,stopping_rule)
        paths = (test_paths[0])[:,::et_dt_forhold]
        paths2 = (test_paths[1])[:,::et_dt_forhold]
        ex_tidspunkt = np.ones(n)*ex_periods
        S1 = paths[:,-1]
        S2 = paths2[:,-1]
        cash_flow = np.maximum(strike-np.minimum(S1,S2),0)*discount_factor
        for i in range(ex_periods-1,0,-1):#payoff for hver sti
            S1 = paths[:,i]
            S2 = paths2[:,i]
            temp_cash_flow = np.maximum(strike-np.minimum(S1,S2),0)
            b00l = temp_cash_flow > 0
            if np.any(b00l):
                if model == "lsm":
                    X_matrix = np.column_stack((S1,S1**2,S1**3,S2,S2**2,S2**3,S1*S2,S1**2*S2,S1*S2**2))
                else:
                    X_matrix = np.column_stack((S1,S2))
                regress = stopping_rule[i]
            else:
                cash_flow *= discount_factor
                continue
            y = regress.predict(X_matrix)
            cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
            ex_tidspunkt[np.logical_and(b00l,temp_cash_flow>=y)] = i
            cash_flow *= discount_factor
        S1 = paths[:,0]
        S2 = paths2[:,0]
        delta = delta_list[0,0]+delta_list[1,0]*S1+delta_list[2,0]*S1**2+delta_list[3,0]*S2+delta_list[4,0]*S1*S2+delta_list[5,0]*S2**2
        delta2 = delta_list2[0,0]+delta_list2[1,0]*S2+delta_list2[2,0]*S2**2+delta_list2[3,0]*S1+delta_list2[4,0]*S1**2+delta_list2[5,0]*S1*S2
        B = price-delta*S1-delta2*S2
        V_final = np.zeros(n)
        for i in range(1,ex_periods+1):#hedge portfølje for hver sti
            S1 = paths[:,i-1]
            S2 = paths2[:,i-1]
            delta = delta_list[0,i-1]+delta_list[1,i-1]*S1+delta_list[2,i-1]*S1**2+delta_list[3,i-1]*S2+delta_list[4,i-1]*S1*S2+delta_list[5,i-1]*S2**2
            delta2 = delta_list2[0,i-1]+delta_list2[1,i-1]*S2+delta_list2[2,i-1]*S2**2+delta_list2[3,i-1]*S1+delta_list2[4,i-1]*S1**2+delta_list2[5,i-1]*S1*S2
            S1 = paths[:,i]
            S2 = paths2[:,i]
            V = delta*S1+delta2*S2+B*1/discount_factor
            if i != ex_periods:
                delta = delta_list[0,i]+delta_list[1,i]*S1+delta_list[2,i]*S1**2+delta_list[3,i]*S2+delta_list[4,i]*S1*S2+delta_list[5,i]*S2**2
                delta2 = delta_list2[0,i]+delta_list2[1,i]*S2+delta_list2[2,i]*S2**2+delta_list2[3,i]*S1+delta_list2[4,i]*S1**2+delta_list2[5,i]*S1*S2
                B = V - delta*S1 - delta2*S2
            b00l = ex_tidspunkt == i
            V_final[b00l] = V[b00l]*discount_factor**i
    else:
        paths1 = monte_carlo_simulation(start_price[0],Rf,sigma[0],n,t_year,dt)[:,::et_dt_forhold]
        paths2 = monte_carlo_simulation(start_price[1],Rf,sigma[1],n,t_year,dt)[:,::et_dt_forhold]
        paths3 = monte_carlo_simulation(start_price[2],Rf,sigma[2],n,t_year,dt)[:,::et_dt_forhold]
        paths4 = monte_carlo_simulation(start_price[3],Rf,sigma[3],n,t_year,dt)[:,::et_dt_forhold]
        paths5 = monte_carlo_simulation(start_price[4],Rf,sigma[4],n,t_year,dt)[:,::et_dt_forhold]
        if model == "lsm":
            price,stopping_rule = lsm_put_minimum_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year,True)
            start_price_list1 = np.random.uniform(start_price[0]*0.9,start_price[0]*1.1,n)
            start_price_list2 = np.random.uniform(start_price[1]*0.9,start_price[1]*1.1,n)
            start_price_list3 = np.random.uniform(start_price[2]*0.9,start_price[2]*1.1,n)
            start_price_list4 = np.random.uniform(start_price[3]*0.9,start_price[3]*1.1,n)
            start_price_list5 = np.random.uniform(start_price[4]*0.9,start_price[4]*1.1,n)
            paths1 = monte_carlo_simulation(start_price_list1,Rf,sigma[0],n,t_year,dt)[:,::et_dt_forhold]
            paths2 = monte_carlo_simulation(start_price_list2,Rf,sigma[1],n,t_year,dt)[:,::et_dt_forhold]
            paths3 = monte_carlo_simulation(start_price_list3,Rf,sigma[2],n,t_year,dt)[:,::et_dt_forhold]
            paths4 = monte_carlo_simulation(start_price_list4,Rf,sigma[3],n,t_year,dt)[:,::et_dt_forhold]
            paths5 = monte_carlo_simulation(start_price_list5,Rf,sigma[4],n,t_year,dt)[:,::et_dt_forhold]
            _,delta_list,delta_list2,delta_list3,delta_list4,delta_list5 = lsm_put_minimum_delta_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year,stopping_rule)
        else:
            price,stopping_rule = mlp1_put_minimum_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year,True)
            start_price_list1 = np.random.uniform(start_price[0]*0.9,start_price[0]*1.1,n)
            start_price_list2 = np.random.uniform(start_price[1]*0.9,start_price[1]*1.1,n)
            start_price_list3 = np.random.uniform(start_price[2]*0.9,start_price[2]*1.1,n)
            start_price_list4 = np.random.uniform(start_price[3]*0.9,start_price[3]*1.1,n)
            start_price_list5 = np.random.uniform(start_price[4]*0.9,start_price[4]*1.1,n)
            paths1 = monte_carlo_simulation(start_price_list1,Rf,sigma[0],n,t_year,dt)[:,::et_dt_forhold]
            paths2 = monte_carlo_simulation(start_price_list2,Rf,sigma[1],n,t_year,dt)[:,::et_dt_forhold]
            paths3 = monte_carlo_simulation(start_price_list3,Rf,sigma[2],n,t_year,dt)[:,::et_dt_forhold]
            paths4 = monte_carlo_simulation(start_price_list4,Rf,sigma[3],n,t_year,dt)[:,::et_dt_forhold]
            paths5 = monte_carlo_simulation(start_price_list5,Rf,sigma[4],n,t_year,dt)[:,::et_dt_forhold]
            _,delta_list,delta_list2,delta_list3,delta_list4,delta_list5 = mlp1_put_minimum_delta_5(paths1,paths2,paths3,paths4,paths5,Rf,strike,t_year,stopping_rule)
        paths1 = (test_paths[0])[:,::et_dt_forhold]
        paths2 = (test_paths[1])[:,::et_dt_forhold]
        paths3 = (test_paths[2])[:,::et_dt_forhold]
        paths4 = (test_paths[3])[:,::et_dt_forhold]
        paths5 = (test_paths[4])[:,::et_dt_forhold]
        ex_tidspunkt = np.ones(n)*ex_periods
        S1 = paths1[:,-1]
        S2 = paths2[:,-1]
        S3 = paths3[:,-1]
        S4 = paths4[:,-1]
        S5 = paths5[:,-1]
        cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)*discount_factor
        for i in range(ex_periods-1,0,-1):#payoff for hver sti
            S1 = paths1[:,i]
            S2 = paths2[:,i]
            S3 = paths3[:,i]
            S4 = paths4[:,i]
            S5 = paths5[:,i]
            temp_cash_flow = np.maximum(strike-np.minimum(S1,S2,np.minimum(S3,S4,S5)),0)
            b00l = temp_cash_flow > 0
            if np.any(b00l):
                if model == "lsm":
                    X_matrix = np.column_stack((S1,S1**2,S2,S2**2,S3,S3**2,S4,S4**2,S5,S5**2,
                        S1*S2,S1*S3,S1*S4,S1*S5,S2*S3,S2*S4,S2*S5,S3*S4,S3*S5,S4*S5))
                else:
                    X_matrix = np.column_stack((S1,S2,S3,S4,S5))
                regress = stopping_rule[i]
            else:
                cash_flow *= discount_factor
                continue
            y = regress.predict(X_matrix)
            cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
            ex_tidspunkt[np.logical_and(b00l,temp_cash_flow>=y)] = i
            cash_flow *= discount_factor
        S1 = paths1[:,0]
        S2 = paths2[:,0]
        S3 = paths3[:,0]
        S4 = paths4[:,0]
        S5 = paths5[:,0]
        delta = delta_list[0,0]+delta_list[1,0]*S1+delta_list[2,0]*S2+delta_list[3,0]*S3+delta_list[4,0]*S4+delta_list[5,0]*S5
        delta2 = delta_list2[0,0]+delta_list2[1,0]*S2+delta_list2[2,0]*S1+delta_list2[3,0]*S3+delta_list2[4,0]*S4+delta_list2[5,0]*S5
        delta3 = delta_list3[0,0]+delta_list3[1,0]*S3+delta_list3[2,0]*S1+delta_list3[3,0]*S2+delta_list3[4,0]*S4+delta_list3[5,0]*S5
        delta4 = delta_list4[0,0]+delta_list4[1,0]*S4+delta_list4[2,0]*S1+delta_list4[3,0]*S2+delta_list4[4,0]*S3+delta_list4[5,0]*S5
        delta5 = delta_list5[0,0]+delta_list5[1,0]*S5+delta_list5[2,0]*S1+delta_list5[3,0]*S2+delta_list5[4,0]*S3+delta_list5[5,0]*S4
        B = price-delta*S1-delta2*S2-delta3*S3-delta4*S4-delta5*S5
        V_final = np.zeros(n)
        for i in range(1,ex_periods+1):#hedge portfølje for hver sti
            S1 = paths1[:,i-1]
            S2 = paths2[:,i-1]
            S3 = paths3[:,i-1]
            S4 = paths4[:,i-1]
            S5 = paths5[:,i-1]
            delta = delta_list[0,i-1]+delta_list[1,i-1]*S1+delta_list[2,i-1]*S2+delta_list[3,i-1]*S3+delta_list[4,i-1]*S4+delta_list[5,i-1]*S5
            delta2 = delta_list2[0,i-1]+delta_list2[1,i-1]*S2+delta_list2[2,i-1]*S1+delta_list2[3,i-1]*S3+delta_list2[4,i-1]*S4+delta_list2[5,i-1]*S5
            delta3 = delta_list3[0,i-1]+delta_list3[1,i-1]*S3+delta_list3[2,i-1]*S1+delta_list3[3,i-1]*S2+delta_list3[4,i-1]*S4+delta_list3[5,i-1]*S5
            delta4 = delta_list4[0,i-1]+delta_list4[1,i-1]*S4+delta_list4[2,i-1]*S1+delta_list4[3,i-1]*S2+delta_list4[4,i-1]*S3+delta_list4[5,i-1]*S5
            delta5 = delta_list5[0,i-1]+delta_list5[1,i-1]*S5+delta_list5[2,i-1]*S1+delta_list5[3,i-1]*S2+delta_list5[4,i-1]*S3+delta_list5[5,i-1]*S4
            S1 = paths1[:,i]
            S2 = paths2[:,i]
            S3 = paths3[:,i]
            S4 = paths4[:,i]
            S5 = paths5[:,i]
            V = delta*S1+delta2*S2+delta3*S3+delta4*S4+delta5*S5+B*1/discount_factor
            if i != ex_periods:
                delta = delta_list[0,i]+delta_list[1,i]*S1+delta_list[2,i]*S2+delta_list[3,i]*S3+delta_list[4,i]*S4+delta_list[5,i]*S5
                delta2 = delta_list2[0,i]+delta_list2[1,i]*S2+delta_list2[2,i]*S1+delta_list2[3,i]*S3+delta_list2[4,i]*S4+delta_list2[5,i]*S5
                delta3 = delta_list3[0,i]+delta_list3[1,i]*S3+delta_list3[2,i]*S1+delta_list3[3,i]*S2+delta_list3[4,i]*S4+delta_list3[5,i]*S5
                delta4 = delta_list4[0,i]+delta_list4[1,i]*S4+delta_list4[2,i]*S1+delta_list4[3,i]*S2+delta_list4[4,i]*S3+delta_list4[5,i]*S5
                delta5 = delta_list5[0,i]+delta_list5[1,i]*S5+delta_list5[2,i]*S1+delta_list5[3,i]*S2+delta_list5[4,i]*S3+delta_list5[5,i]*S4
                B = V - delta*S1 - delta2*S2 - delta3*S3 - delta4*S4 - delta5*S5
            b00l = ex_tidspunkt == i
            V_final[b00l] = V[b00l]*discount_factor**i
    hedging_error = (V_final-cash_flow)/price
    return np.mean(hedging_error), np.std(hedging_error)

def hedging_experiment_mlp(test_paths,Rf,sigma,n,strike,mlp_model,t_year,et=50,et_dt_forhold=1):
    ex_periods = int(et*t_year)
    discount_factor = np.exp(-Rf*1/et)
    if len(test_paths) != 2:
        x = np.atleast_2d([test_paths[0,0]/strike,sigma,t_year])
        price = mlp_model.predict(x)*strike
        paths = test_paths[:,::et_dt_forhold]
        ex_tidspunkt = np.ones(n)*ex_periods
        cash_flow = np.maximum(strike-paths[:,-1],0)*discount_factor
        sigma_list = np.full(n,sigma)
        t_year_list = np.full(n,t_year)
        for i in range(ex_periods-1,0,-1):#payoff for hver sti
            temp_cash_flow = np.maximum(strike-paths[:,i],0)
            b00l = temp_cash_flow > 0
            if np.any(b00l):
                X_matrix = np.column_stack((paths[:,i]/strike,sigma_list,t_year_list-i/et))
            else:
                cash_flow *= discount_factor
                continue
            y = mlp_model.predict(X_matrix)*strike
            cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
            ex_tidspunkt[np.logical_and(b00l,temp_cash_flow>=y)] = i
            cash_flow *= discount_factor
        epsilon = 10**(-6)
        X1 = np.column_stack((paths[:,0]/strike,sigma_list,t_year_list))
        X2 = np.column_stack((paths[:,0]/strike+epsilon,sigma_list,t_year_list))
        delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
        B = price-delta*paths[:,0]
        V_final = np.zeros(n)
        for i in range(1,ex_periods+1):#hedge portfølje for hver sti
            X1 = np.column_stack((paths[:,i-1]/strike,sigma_list,t_year_list-(i-1)/et))
            X2 = np.column_stack((paths[:,i-1]/strike+epsilon,sigma_list,t_year_list-(i-1)/et))
            delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
            V = delta*paths[:,i]+B*1/discount_factor
            if i != ex_periods:
                X1 = np.column_stack((paths[:,i]/strike,sigma_list,t_year_list-i/et))
                X2 = np.column_stack((paths[:,i]/strike+epsilon,sigma_list,t_year_list-i/et))
                delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
                B = V - delta*paths[:,i]
            b00l = ex_tidspunkt == i
            V_final[b00l] = V[b00l]*discount_factor**i
    else:
        x = np.atleast_2d([(test_paths[0])[0,0]/strike,(test_paths[1])[0,0]/strike,sigma[0],sigma[1],t_year])
        price = mlp_model.predict(x)*strike
        paths = (test_paths[0])[:,::et_dt_forhold]
        paths2 = (test_paths[1])[:,::et_dt_forhold]
        ex_tidspunkt = np.ones(n)*ex_periods
        cash_flow = np.maximum(strike-np.minimum(paths[:,-1],paths2[:,-1]),0)*discount_factor
        sigma_list = np.full(n,sigma[0])
        sigma2_list = np.full(n,sigma[1])
        t_year_list = np.full(n,t_year)
        for i in range(ex_periods-1,0,-1):#payoff for hver sti
            temp_cash_flow = np.maximum(strike-np.minimum(paths[:,i],paths2[:,i]),0)
            b00l = temp_cash_flow > 0
            if np.any(b00l):
                X_matrix = np.column_stack((paths[:,i]/strike,paths2[:,i]/strike,sigma_list,sigma2_list,t_year_list-i/et))
            else:
                cash_flow *= discount_factor
                continue
            y = mlp_model.predict(X_matrix)*strike
            cash_flow[np.logical_and(b00l,temp_cash_flow>=y)] = temp_cash_flow[np.logical_and(b00l,temp_cash_flow>=y)]
            ex_tidspunkt[np.logical_and(b00l,temp_cash_flow>=y)] = i
            cash_flow *= discount_factor
        epsilon = 10**(-6)
        X1 = np.column_stack((paths[:,0]/strike,paths2[:,0]/strike,sigma_list,sigma2_list,t_year_list))
        X2 = np.column_stack((paths[:,0]/strike+epsilon,paths2[:,0]/strike,sigma_list,sigma2_list,t_year_list))
        delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
        X2 = np.column_stack((paths[:,0]/strike,paths2[:,0]/strike+epsilon,sigma_list,sigma2_list,t_year_list))
        delta2 = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
        B = price-delta*paths[:,0]-delta2*paths2[:,0]
        V_final = np.zeros(n)
        for i in range(1,ex_periods+1):#hedge portfølje for hver sti
            X1 = np.column_stack((paths[:,i-1]/strike,paths2[:,i-1]/strike,sigma_list,sigma2_list,t_year_list-(i-1)/et))
            X2 = np.column_stack((paths[:,i-1]/strike+epsilon,paths2[:,i-1]/strike,sigma_list,sigma2_list,t_year_list-(i-1)/et))
            delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
            X2 = np.column_stack((paths[:,i-1]/strike,paths2[:,i-1]/strike+epsilon,sigma_list,sigma2_list,t_year_list-(i-1)/et))
            delta2 = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
            V = delta*paths[:,i]+delta2*paths2[:,i]+B*1/discount_factor
            if i != ex_periods:
                X1 = np.column_stack((paths[:,i]/strike,paths2[:,i]/strike,sigma_list,sigma2_list,t_year_list-i/et))
                X2 = np.column_stack((paths[:,i]/strike+epsilon,paths2[:,i]/strike,sigma_list,sigma2_list,t_year_list-i/et))
                delta = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
                X2 = np.column_stack((paths[:,i]/strike,paths2[:,i]/strike+epsilon,sigma_list,sigma2_list,t_year_list-i/et))
                delta2 = (mlp_model.predict(X2)-mlp_model.predict(X1))/epsilon
                B = V - delta*paths[:,i]-delta2*paths2[:,i]
            b00l = ex_tidspunkt == i
            V_final[b00l] = V[b00l]*discount_factor**i
    hedging_error = (V_final-cash_flow)/price
    return np.mean(hedging_error), np.std(hedging_error)
