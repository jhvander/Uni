#include <oxstd.h>
#include <oxfloat.h>
#include <oxdraw.h>
#include <oxprob.h>


//
// ols estimation
// the row yy on the rows in xx
//
ols_estimation( yy , xx , pr=FALSE )
  {
  decl z,y,x,ols_loglik,ols_residual,ols_para,ols_std,ols_tval,ols_omega,xxpara,n,p,k;

  //dimensions
  p = rows(yy);
  k = rows(xx);

  //remove any missing values due to lags
  z = deletec(yy|xx);
  y = z[0:p-1][];
  x = z[p:   ][];
  n = columns(y);

  //estimation and statistics    
  olsr(y, x, &ols_para, &xxpara);  
  ols_residual  = y-ols_para*x;
  ols_omega     = ols_residual*ols_residual'/n;
  ols_std       = shape(diagonal(xxpara**ols_omega).^.5,p,k);
  ols_tval      = ols_para./ols_std;
  ols_loglik    = -0.5*n*log(determinant(ols_omega))-0.5*n*p*(1+log(M_2PI));

  //print
  if(pr==TRUE)
    {
    print("\n\n*\n* *\n* * *\n");
    print("OLS:\n");
    println("n      = ","%15.0f" ,n);
    println("p      = ","%15.0f" ,p);
    println("k      = ","%15.0f" ,k);
    println("loglik = ","%#15.5f",ols_loglik[0][0]);
    println("Omega  = ","%#15.5f",ols_omega[0][0]);
    print("\nEstimates",ols_para);
    print("\ns.e."     ,ols_std);
    print("\nt-values" ,ols_tval);
    }

  //return array
  return { ols_loglik , ols_residual , ols_para , ols_std };
  }


//
// generate AR(1) data
// y(t) = delta + rho*y(t-1) + eps(t)
// with y0 given
// the row of eps contains T shocks.
//
Generate( delta , rho , y0 , eps )
  {
  decl y;
  
  //initial value
  y = constant( y0 , 1 , 1+columns(eps) );

  //loop over t
  for( decl t=1 ; t<=columns(eps) ; ++t )
    {
    y[0][t]      = delta + rho*y[0][t-1] + eps[0][t-1];
    }

  //return series  
  return y;
  }
  

//
// generate AR(1) data with heteroskedasticity
// second half has a larger variance
//
Generate_het( delta , rho , x0 , eps )
  {
  decl y;
  
  //initial value
  y      = constant( x0 , 1 , 1+columns(eps) );

  //loop over t
  for( decl t=1 ; t<=columns(eps) ; ++t )
    {
    if(t>columns(eps)/2)
      {
      y[0][t]      = delta + rho*y[0][t-1] + 4*eps[0][t-1];
      }
    else
      {
      y[0][t]      = delta + rho*y[0][t-1] + eps[0][t-1];
      }
    }

  //return series  
  return y;
  }


//  
// lr test on rho in an AR(1)
// H0: rho=b
//
LR( y , b , pr=FALSE)
  {
  decl h,loglik_U,loglik_R,LR,z_tilde,theta_tilde,z_hat,theta_hat,pval;

  //estimations
  [loglik_U , z_hat   , theta_hat   ] = ols_estimation( y                , lag(y',1)' | ones(1,columns(y)) );
  [loglik_R , z_tilde , theta_tilde ] = ols_estimation( y - b*lag(y',1)' ,              ones(1,columns(y)) );

  //test statistic and p-value
  LR                                  = 2*(loglik_U-loglik_R);
  pval   							  = tailchi(LR,1);

  //print
  if(pr==TRUE)
    {
    print("\n\n*\n* *\n* * *\n");
    print("Likelihood ratio test:");
    println("%r",{"b","LR","Chi2(1) p-val"},b|LR|pval);
    }

  //return
  return { LR , pval , z_tilde , theta_tilde , theta_hat };
  }


//
// generate bootstrap shocks
//
Resample( X , type , pr=FALSE )
  {
  decl shock,id;
  decl x1,x2,p;

  // moments of auxiliary distributions
  //
  //            1     2     3     4		5	  6
  //Mammen      0     1     1     2     3     5
  //Rademacher  0     1     0     1		0	  1
  //Normal      0     1     0     3		0	 15
  //Davidson    a=1 => rademacher  a = (1+sqrt(5))/2 =>mammen
  
  if(isdouble(type)==1)
    {
    //wild bootstrap (Davidson)
    decl a = type;
    id    = (a+1/a)*ranbinomial(1,columns(X),1, 1/(1+a^2) ) - (1/a);
    shock = X.*id;

    //print moments
    if(pr==TRUE)
      {
      p  = 1/(1+a^2);
      x1 = a;
      x2 = -1/a;
      print("\n\n***************************");
      print("\nResampling bootstrap shocks\nusing Davidson distribution");
      print("\n  1. moment: ","%#7.3f",p*x1  +(1-p)*x2  );
      print("\n  2. moment: ","%#7.3f",p*x1^2+(1-p)*x2^2);
      print("\n  3. moment: ","%#7.3f",p*x1^3+(1-p)*x2^3);
      print("\n  4. moment: ","%#7.3f",p*x1^4+(1-p)*x2^4);
      print("\n  5. moment: ","%#7.3f",p*x1^5+(1-p)*x2^5);
      print("\n  6. moment: ","%#7.3f",p*x1^6+(1-p)*x2^6);
      print("\n***************************");
      }
    }
  else
    {
    if(type=="Mammen" || type=="mammen" || type=="MAMMEN")
      {
      //wild bootstrap (Mammen)
      id    = 0.5+0.5*sqrt(5)*(2*ranbinomial(1,columns(X),1, (sqrt(5)-1)/(2*sqrt(5)) )-1);
      shock = X.*id;
      
      //print moments
      if(pr==1)
        {
        p  = (sqrt(5)-1)/(2*sqrt(5));
        x1 = 0.5+sqrt(5)/2;
        x2 = 0.5-sqrt(5)/2;
        print("\n\n***************************");
        print("\nResampling bootstrap shocks\nusing Mammen distribution");
        print("\n  1. moment: ","%#7.3f",p*x1  +(1-p)*x2  );
        print("\n  2. moment: ","%#7.3f",p*x1^2+(1-p)*x2^2);
        print("\n  3. moment: ","%#7.3f",p*x1^3+(1-p)*x2^3);
        print("\n  4. moment: ","%#7.3f",p*x1^4+(1-p)*x2^4);
        print("\n  5. moment: ","%#7.3f",p*x1^5+(1-p)*x2^5);
        print("\n  6. moment: ","%#7.3f",p*x1^6+(1-p)*x2^6);
        print("\n***************************");
        }
      }
    if(type=="Rademacher" || type=="rademacher" || type=="RADEMACHER")
      {
      //wild bootstrap (Rademacher)
      id    = (2*ranbinomial(1,columns(X),1,0.5)-1);
      shock = X.*id;

      //print moments
      if(pr==1)
        {
        p  = 0.5;
        x1 =  1;
        x2 = -1;
        print("\n\n***************************");
        print("\nResampling bootstrap shocks\nusing Rademacher distribution");
        print("\n  1. moment: ","%#7.3f",p*x1  +(1-p)*x2  );
        print("\n  2. moment: ","%#7.3f",p*x1^2+(1-p)*x2^2);
        print("\n  3. moment: ","%#7.3f",p*x1^3+(1-p)*x2^3);
        print("\n  4. moment: ","%#7.3f",p*x1^4+(1-p)*x2^4);
        print("\n  5. moment: ","%#7.3f",p*x1^5+(1-p)*x2^5);
        print("\n  6. moment: ","%#7.3f",p*x1^6+(1-p)*x2^6);
        print("\n***************************");
        }
      }
    if(type=="Normal" || type=="normal" || type=="NORMAL")
      {
      //wild bootstrap (Gaussian distribution)
      id    = rann(1,columns(X));
      shock = X.*id;

      //print moments
      if(pr==1)
        {
        p  = 0.5;
        x1 =  1;
        x2 = -1;
        print("\n\n***************************");
        print("\nResampling bootstrap shocks\nusing Gaussian distribution");
        print("\n  1. moment: ","%#7.3f",0 );
        print("\n  2. moment: ","%#7.3f",1);
        print("\n  3. moment: ","%#7.3f",0);
        print("\n  4. moment: ","%#7.3f",3);
        print("\n  5. moment: ","%#7.3f",0);
        print("\n  6. moment: ","%#7.3f",15);
        print("\n***************************");
        }
      }
    else if(type=="iid" || type=="i.i.d." || type=="IID")
      {
      //iid bootstrap (random draws with replacement)
      id    = floor(ranu(1,columns(X))*columns(X));
      shock = X[][id];
      }
    else if(type=="Permutation" || type=="permutation" || type=="PERMUTATION")
      {
      //permutation (random draws without replacement)
      shock = ranshuffle(columns(X),X);
      }
     }
     
  //return  
  return shock;
  }

  
//  
// bootstrap test on rho in an AR(1) with constant term
// H0: rho=b
// uses B samples with either "iid" or "normal" or "rademacher" or "mammen"
//
Bootstrap_LR( y , b , B , type="iid" , pr=FALSE)
  {
  decl LR0,pval0,pval,z_tilde,z_c,theta_tilde;
  decl LRB,resB,zB,yB,id;

  //in case we need unrestricted residuals...
  //decl z_hat ;  [LR0 , pval , z_hat] = LR( y , 0.8 , FALSE);

  //test on original data
  [ LR0 , pval0 , z_tilde , theta_tilde ] = LR( y , b );

  //bootstrap loop
  resB = nans(B,1);
  parallel for(decl i=0;i<B;++i)
    {
	//recenter restricted residuals
    z_c = z_tilde-meanr(z_tilde);

    //in case we use unrestricted residuals...
	//z_c = z_hat-meanr(z_hat);

	//resampling
    zB = Resample( z_c , type );

    //construct bootstrap series
    yB = Generate( theta_tilde , b , y[0][0] , zB );

    //test on bootstrap data
    [ LRB ]   = LR( yB , b );

	//collect results
    resB[i][] = LRB;
    }

  //bootstrap pvalue
  pval = meanc(resB.>=LR0);
  
  //print
  if(pr==TRUE)
    {
    print("\n\n*\n* *\n* * *\n");
    print("Bootstrap likelihood ratio test:");
    println("%r",{"b","LR","Chi2(1) p-val","Bootstrap p-val","B"},b|LR0|pval0|pval|B);
    print("\nbootstrap: ",type);
    }

  //return p-value and bootstrap distribution 
  return { pval , resB };
  }

  