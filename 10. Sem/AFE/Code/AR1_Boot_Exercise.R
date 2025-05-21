rm(list=ls())
library(latex2exp) # only used in plots

# For plotting
QQChiSq1 <- function(y,clr="deepskyblue2") {
  M <- length(y)
  p <- seq(from = 1 / (2 * M), to = (2 * M - 1) / (2 * M), by = 1 / M)
  qx <- qchisq(p,1)
  qy <- y[order(y)]
  
  # Make plot
  q99 <- qchisq(0.99,1)
  plot(qx,qy,xlim=c(0,q99),ylim=c(0,q99),xlab="",ylab="")
  
  # Add straight line
  reg <- lm(qy ~ qx)
  abline(reg,col=clr,lwd=2)
}
DistChiSq1 <- function(y,clr="deepskyblue2") {
  q999 <- qchisq(0.999,1)
  hist(y, 
       breaks = 200, 
       freq = FALSE, 
       xlim = c(0,q999), 
       xlab = '', 
       main = '', cex.main=0.9,
       col=clr)
  xfit<-seq(0,max(y),length=1000)
  yfit<-dchisq(xfit, df = 1)
  lines(xfit,yfit, col="black", lwd=2)
}
Make_plot <- function() {
  par(mfrow=c(2,2),mar=c(1,4,4,1),cex=0.9,mai=c(0.3,0.4,0.1,0.1),oma=c(0.2, 1, 0.1, 0.1))
  capT <- length(x)
  t <- 0:(capT-1)
  ylim <- c(min(x),max(x))
  
  # generating examples of bootstrap series to compare
  restricted_est <- EpsTilde(x,rho)
  deltaTilde <- restricted_est[[1]]
  epsTilde <- restricted_est[[2]]
  xStars <- Sim_xStar(deltaTilde,rho,x0,epsTilde,scheme)
  lower <- min(ylim[1],min(xStars))
  upper <- max(ylim[2],max(xStars))
  ylim <- c(lower,upper)
  for (i in 2:3) {
    xStar <- Sim_xStar(deltaTilde,rho,x0,epsTilde,scheme)
    lower <- min(ylim[1],min(xStar))
    upper <- max(ylim[2],max(xStar))
    ylim <- c(lower,upper)
    xStars <- rbind(xStars,xStar)
  }
  
  # original series
  plot(t,x,type="l",col="red",lwd=2,ylim=ylim)
  title(TeX(paste0("$x_t$ with $\\rho_0 = $",rho,", $\\delta_0 = $",delta,", $x_0 = $",x0," and $\\sigma^2_0 = $",sigma2,"")),
        adj = 0.05, line=-1.0,cex.main=1.3)
  
  clrs <- c("black","deepskyblue2","darkolivegreen4")
  plot(t,xStars[1,],type="l",col=clrs[1],lwd=2,ylim=ylim,ylab="",xlab="")
  for (i in 2:3) points(t,xStars[i,],type="l",col=clrs[i],lwd=2)
  title(TeX("Examples of $x^{*}_t$"),
        adj = 0.05, line=-1.0,cex.main=1.3)
  
  # Empirical distribution of bootstrapped LR-statistic
  DistChiSq1(LRstar)
  abline(v=c(LR,qchisq(0.95,1)), col=c("red", "black"), lty=c(2,2), lwd=c(2, 2))
  title(TeX(paste0("LR* with B = ",B," and ",scheme,"-sampling scheme")),
        adj = 0.3, line=-1.0,cex.main=1.3)
  title(TeX(paste0("red = LR-stat., black = $q_{0.95}$ of $\\chi^2_{(1)}$")),
        adj = 0.17, line=-2.5,cex.main=1.3)
  
  QQChiSq1(LRstar)
  title(TeX(paste0("Quantiles of $\\chi^2_{(1)}$ vs LR*")),
        adj = 0.05, line=-1.0,cex.main=1.3)
}

# Simulation and estimation
Sim_x <- function(rho,delta,sigma2,x0,capT) {
  
  # Draw innovations
  eps <- rnorm(capT,sd=sqrt(sigma2))
  
  # Generate AR(1)-process
  x <- rep(x0,capT)
  for (t in 2:capT) x[t] <- delta + rho * x[t - 1] + eps[t]

  # Return simulated series
  x
}
Sim_xStar <- function(deltaStar,rhoStar,x0Star,epsTilde,scheme=c("iid","wild")) {
  
  # Number of estimated residuals
  capT <- length(epsTilde)
    
  if (scheme=="iid") {
    # Note: We are estimating with a constant so they already have empirical mean zero, but just to illustrate
    epsTildeC <- epsTilde - mean(epsTilde) 
    
    # Discrete uniforms on {1,...,capT}
    u <- sample(1:capT,capT,replace=T)
    
    # Resample with replacement (iid resampling scheme)
    epsStar <- epsTildeC[u]
  } else {
    w <- rnorm(capT)
    epsStar <- w * epsTilde
  }
  
  
  # Generate boostrap data
  xStar <- rep(x0Star,capT + 1) # Note: we do not have an eps0
  for (t in 2:capT) xStar[t] <- deltaStar + rhoStar * xStar[t - 1] + epsStar[t]
  
  # Return bootstrap data
  xStar
}
Loglik <- function(x) {
  
  # Number of observations
  capT <- length(x)
  
  # Construct matrices for estimation
  Y <- x[2:capT]
  X <- rbind(rep(1.0,capT - 1),x[1:(capT - 1)])
  
  # Estimate by OLS (coincides with the MLE)
  Xinv <- solve(X %*% t(X))
  thetaHat <- t(Xinv %*% (X %*% Y))
  
  # Estimate variance of innovations
  epsHat <- Y - thetaHat %*% X
  RSS <- sum(epsHat ^ 2)
  sigma2Hat <- RSS / capT
  
  # Calculate value of log-likelihood at MLE for LR-statistic
  -0.5 * (capT * log(sigma2Hat) + RSS / sigma2Hat)
}
Loglik_H0 <- function(x,rho0) {
  # Number of observations
  capT <- length(x)
  
  # Estimate by OLS (coincide with restricted MLE)
  tmp <- x[2:capT] - rho0 * x[1:(capT - 1)]
  deltaTilde <- mean(tmp)
  
  # Estimate variance of innovations
  epsTilde <- tmp - deltaTilde
  RSS <- sum(epsTilde ^ 2)
  sigma2Hat <- RSS / capT
  
  # Calculate value of log-likelihood at MLE for LR-statistic
  -0.5 * (capT * log(sigma2Hat) + RSS / sigma2Hat)
}
EpsTilde <- function(x,rho0) {
  # Number of observations
  capT <- length(x)
  
  # Estimate by OLS (coincide with restricted MLE)
  tmp <- x[2:capT] - rho0 * x[1:(capT - 1)]
  deltaTilde <- mean(tmp)
  epsTilde <- tmp - deltaTilde
  
  # Return restricted MLE and restricted residuals
  list(deltaTilde,epsTilde)
}

# True parameters
delta <- 0
rho <- 0.8
x0 <- 0
sigma2 <- 1

# Number of observations and bootstrap replications
capT <- 100
B <- 3999
scheme <- "iid"
rhoStar <- rho # The hypothesis we are testing

# Simulate "true" data
set.seed(1)
x <- Sim_x(rho,delta,sigma2,x0,capT)

# Calculate conventional / original LR-statistic 
LR <- 2 * (Loglik(x) - Loglik_H0(x,rhoStar))

# Restricted MLE and estimated restricted residuals
restricted_est <- EpsTilde(x,rhoStar)
deltaTilde <- restricted_est[[1]]
epsTilde <- restricted_est[[2]]

# Bootstrap algorithm
LRstar <- rep(0,B)
for (b in 1:B) {
  xStar <- Sim_xStar(deltaTilde,rhoStar,x0,epsTilde,scheme)
  LRstar[b] <- 2 * (Loglik(xStar) - Loglik_H0(xStar,rhoStar))
}

# Generates all the plots in the exercise (uses a lot of the generated variables)
Make_plot()
print(paste0("bootstrap p-value = ",round(mean(LR <= LRstar),4),""))
