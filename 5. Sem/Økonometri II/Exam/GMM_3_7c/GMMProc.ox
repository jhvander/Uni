#include <oxstd.h>
#include <oxfloat.h>
#include <oxdraw.h>
#include <oxprob.h>
#import  <maximize>

decl Y,Z,a;
decl Uvec,Gmat,Gmat2;
decl adFunc,genval,avScore,amHessian,wn,nobs;
decl kernel,indik,wmethod,kernname,kern,manualband,wconst,bandw;
decl i_onestep,i_twostep,i_iterated,i_cu,kernelprint,Wprint,Uvecprint,maxit;
decl n_model,m_model,s_model,names_y,names_z;
decl savemode = <>;
decl saveUvec = <>;
decl names_P;
decl iniW=0;
mom(const a);
decl J0,K0,names;

//least squares concentration (rows)
conc(ind, bet)
  {
  decl pi,ret;

  if(bet==0)
    {
    ret = ind;
    }
  else
    {
    olsr(ind , bet , &pi);
    ret = ind - pi*bet;
    }
    
  return ret;
  }

//control that a text is in an array
IsIn(a,B)
  {
  decl is=-1;

  for(decl i=0;i<rows(B);++i)
    {
    if(a==B[i])
      {
      is=i;
      break;
      }
    }

  return is;
  }

//sample moment conditions
gen(a)
  {
  return meanc(mom(a))';
  }
//gen_help(theta,adFunc,avScore,amHessian)
//  {
//  adFunc[0] = gen(theta)[indik][0];  
//  return 1;
//  }
gen_jac(adFunc,theta)
  {
  adFunc[0] = gen(theta);
  
  return 1;
  }

//criteria function (conditional on the weights)
crit(theta,adFunc,avScore,amHessian)
  {
  adFunc[0] = -gen(theta)'wn*gen(theta);  
  return 1;
  }

//estimator of the variance matrix
hac(e)
  {
  decl i,t,k,a1,a2,j,xx,delta,sig,ac,e1,e2,rho,sgm,nlags,w,X;
  
  if(wmethod==0)
    {
    //IID weight matrix: requires Uvec to be defined
    X   = Z[0];
    for(i=1;i<=rows(Z)-1;++i)
      {
      X=X~Z[i];
      }
    sig = ((1/rows(e))*Uvec'Uvec)*X'X;
    }
  if(wmethod>=1)
    {
    //HC estimator
    sig = e'e;
    }
  if(wmethod==2)
    {
    //HAC correction for autocorrelation

    //some information
    k        = columns(e);
    t        =    rows(e);
    rho      = zeros(k,1);
    sgm      = zeros(k,1);
    nlags    =        t-2; // number of lags: (t-2) is the full sample
    
    //estimate AR(1) to get parameters for bandwidth
    for(j=0;j<=k-1;++j)
      {
      e1     = e[1:t-1][j];
      e2     = e[0:t-2][j];
      rho[j] = invert(e2'e2)*(e1'e2);    //rho
      sgm[j] = meanc((e1-e2*rho[j]).^2); //sigma2
      }
    //print(meanc(rho));

    //weights in bandwidth constants
    if(wconst==0)
      {
      w = 0|ones(k-1,1);
      }
    else
      {
      w = ones(k,1);
      }

    //bandwidth constants  
    a1 = 4*sumc(w.*(rho.^2).*(sgm.^2)./(((1-rho).^6).*((1+rho).^2)) ) / sumc(w.*(sgm.^2)./((1-rho).^4));
    a2 = 4*sumc(w.*(rho.^2).*(sgm.^2)./((1-rho).^8)                 ) / sumc(w.*(sgm.^2)./((1-rho).^4));

    //calculate kernel values  
    if(kernel==0)
      {
      //Bartlett kernel
      if(manualband==0)  bandw = 1.1447*(a1*t)^(1/3);
      else               bandw = manualband;            
      kernname = sprint("Bartlett kernel, bandwidth=","%-5.3g",bandw[0][0]);
      xx       = range(1,t-1)/bandw;
      kern     = (1-xx).*((1-xx).>0);      
      }
    else if(kernel==1)
      {
      //Quadratic spectral kernel
      if(manualband==0)  bandw = 1.3221*(a2*t)^.2;
      else               bandw = manualband;            
      kernname = sprint("Quadratic spectral kernel, bandwidth=","%-5.3g",bandw[0][0]);
      xx       = range(1,t-1)/bandw;
      delta    = xx*1.2*M_PI;
      kern     = 3*((sin(delta)./delta-cos(delta))./(delta.^2));    
      }
    else if(kernel==2)
      {
      //Parzen kernel
      if(manualband==0)  bandw = 2.6614*(a2*t)^.2;
      else               bandw = manualband;            
      kernname = sprint("Parzen kernel, bandwidth=","%-5.3g",bandw[0][0]);
      xx       = range(1,t-1)/bandw;
      kern     = (1-6*(xx.^2)+6*(xx.^3)).*(xx.<=0.5).*(xx.>=0)+(2*((1-xx).^3)).*(xx .<=1).*(xx.>0.5);
      }
    else
      {
      //Truncated kernel
      if(manualband==0)  bandw = 12;
      else               bandw = manualband;            
      kernname = sprint("Truncated kernel, bandwidth=","%-5.3g",bandw[0][0]);
      xx       = range(1,t-1)/bandw;
      kern     = ((1-xx).^0).*((1-xx).>0);      
      }

    //autocorrelation correction  
    ac  = zeros(k,k);
    for(j=1;j<=nlags;++j)
      {
      ac  = (e[0:t-1-j][]'e[j:t-1][]);
      sig = sig + kern[j-1]*(ac+ac');
      }
    }
  
  return sig;
  }

//weight matrix as a function of theta  
wn_cu(theta)
  {
  //print(hac(mom(theta))/nobs);
  return invertsym( hac(mom(theta))/nobs );
  }

//criteria function for continously updated GMM  
crit_cu(theta,adFunc,avScore,amHessian)
  {
  adFunc[0] = -gen(theta)'wn_cu(theta)*gen(theta);
  return 1;
  }

//replace with variable names
ReplaceNames(text,Ynames,Znames)
  {
  decl A = text;
  for(decl i=0;i<rows(Ynames);++i)
    {
    A = replace(A,sprint("Y[",i,"]"),Ynames[i]);
    }
  for(decl i=0;i<rows(Znames);++i)
    {
    A = replace(A,sprint("Z[",i,"]"),Znames[i]);
    }
  return A;
  }


//prints estimation output
gmmprint(n_model,names_y,names_z,etype,wtype,maxq,jn,pval,names,a,sterr,k,kname=" ",iter=1,Wprint=0)
  { 
  format(800);
  decl Etype,Wtype,Kname;

  //set types  
  if(wtype==0)
    {
    Wtype = "IID estimator";
    Kname = "...";
    }
  if(wtype==1)
    {
    Wtype = "HC estimator";
    Kname = "...";
    }
  if(wtype==2)
    {
    Wtype = "HAC estimator";
    Kname = kname;
    }

  //set estimator  
  if(etype==1)
    {                      
    Etype = "Two-step Efficient GMM";
    }
  else if(etype==2)
    {
    Etype = "Iterated GMM";
    }
  else if(etype==3)
    {
    Etype = "Continously updated GMM";
    }
  else
    {
    Etype = "One-step GMM";
    Wtype = "Fixed at initial choice";
    }
  
  //main output  
  print("\nGMM(","%2d",n_model,") **********************************************************************\n");

  //estimates
  println("%c",{"Coefficient","Std.Error","t-value"},"%r",names,"%cf",{"%16.6g","%11.4g","%9.3g"},a~sterr~(a./sterr));

  //moment conditions 
  print("\nModel and moment conditions:\n\n");
  for(decl i=0;i<=rows(m_model)-1;++i)
    {
    if(isstring(m_model[i])==1)
      if(m_model[i]!="")      
        print(ReplaceNames(m_model[i],names_y,names_z) ,"\n");
    }
  //print("\n        ");
  
  //extra information
  println("\nEstimator              "+Etype);
  println("Iterations             ",iter);
  println("Weight matrix          "+Wtype);
  println("HAC kernel             "+Kname);
  println("Estimation sample      "+s_model);
  println("Observations (T)       ","%-11.0f",nobs);
  println("Parameters (k)         ","%-11.0f",rows(names));
  println("Moment conditions (R)  ","%-11.0f",k);
  println("Criteria function (Q)  ","%-11.6f",-maxq[0][0]); 
  println("J-statistic (T*Q)      ","%-6.2f",jn[0][0],"[","%5.3f",pval[0][0],"] in a Chi2(",(k-rows(a))[0][0],")\n");        
  print  ("Initial weight matrix  ");
  if(iniW==unit(k))
    {
    println("Unit matrix");
    }
  else
    {
    print(iniW);
    }
  

  print("\nMEMO: Variables and code:     Model     Instr.");
  //variables
  decl dz=0;
  for(decl i=0;i<rows(Y);++i)
    {
    decl d=IsIn(names_y[i],names_z);
    if(d>=0)
      {
      print("\n                              Y[","%2d",i,"]  =  Z[","%2d",dz,"]  =  ",names_y[i]);
      dz=dz+1;
      }
    else
      {
      print("\n                              Y[","%2d",i,"]            =  ",names_y[i]);
      }
    }
  for(decl i=0;i<rows(Z);++i)
    {
    decl d=IsIn(names_z[i],names_y);
    if(d==-1)
      {
      print("\n                                        Z[","%2d",dz,"]  =  ",names_z[i]);
      dz=dz+1;
      }
    }

  //moment conditions  
  print("\n\n");
  for(decl i=0;i<=rows(m_model)-1;++i)
    {
    if(isstring(m_model[i])==1)
      if(m_model[i]!="")      
        print("      "+m_model[i],"\n");
    }
  print("\n        ");

  if(Wprint==1) 
    {
    print("\nFinal variance of moments (S):","%13.4g",invertsym(wn));
    print("\nFinal weight matrix (W=inverse(S)):","%13.4g",wn);
    }
  }
  
//main GMM procedure
gmmfunc(wm,...)
  {
  decl i,j;
  decl maxq,ggg,m,mm,jn,pval,iter,om,sterr,p,k;
  decl maxiter,maxq0,change;
  decl args = va_arglist();
  decl a0;

  //initialize  
  nobs   = rows(Y[0]);                 //number of observations
  k      = columns(mom(zeros(100,1))); //number of moments
  a      = 0.1+zeros(k,1);                 //initial values of parameters
  a0     = a;
  jn     = <.NaN>;
 
  //initial weight matrix
  if(ismatrix(iniW)==1)
    {
    if(rows(iniW)==k && columns(iniW)==k)
      {
      wn = iniW;
      }
    }
  else
    {
    iniW   = unit(k);
    wn     = iniW;                    
    }
  
  //weight estimation: 0=IID, 1=HC, 2=HAC
  wmethod=wm;
  
  //set additional options
  //(1) Kernel: 1=Bartlett, 2=Quadratic spectral, 3=Parzen ,4=truncated
  if(sizeof(args)>=1) kernel      = args[0];
  else                kernel      =       0; //default
  //(2) Bandwidth: 0=automatic, else actual bandwith
  if(sizeof(args)>=2) manualband  = args[1];
  else                manualband  =       0;
  //(3) zero weight in automatic bandwidth formula for first moment (constant term)
  if(sizeof(args)>=3) wconst      = args[2];
  else                wconst      =       1; //default
  //(4) one-step
  if(sizeof(args)>=4)  i_onestep  = args[3];
  else                 i_onestep  =       1;
  //(5) two-step
  if(sizeof(args)>=5)  i_twostep  = args[4];
  else                 i_twostep  =       1;
  //(6) Iterated
  if(sizeof(args)>=6)  i_iterated = args[5];
  else                 i_iterated =       1;
  //(7) cu
  if(sizeof(args)>=7)  i_cu       = args[6];
  else                 i_cu       =       1;
  //(8) maxiter
  if(sizeof(args)>=8)  maxit      = args[7];
  else                 maxit      =     500;
  //(8) kernelprint
  if(sizeof(args)>=9)  kernelprint= args[8];
  else                 kernelprint=       1;
  if(sizeof(args)>=10) Wprint     = args[9];
  else                 Wprint     =       0;
    
  //names for output
  names = names_P;

  if(rows(names)>k)
    {
    print("\nGMM(","%2d",n_model,") **********************************************************************\n"); 
    print("\n...The model is not identified, R=",rows(names)," < ",k,"=k\n\nPlease reformulate...\n");
    return ;
    }
    
  //Iterative GMM
  maxiter =    2+(i_iterated*(maxit-2));
  maxq0   =  100;

  //start interations
  for(i=1;i<=maxiter;++i)
    {
    //numerical optimization
    MaxControl(10000, 0, 0);
    MaxControlEps(1e-10, 1e-8);
    MaxBFGS(crit, &a, &maxq, 0, 1);

    //determine the number of parameters
    if(i==1)
      {
      //a     = deleteifr(a,a.==0.1);
      a     = deleteifr(a,fabs(a-a0).<constant(0.00001,k,1));
      p     = rows(a);
      }
      
//print("n...",p,"  ",k);
    //first derivatives
    NumJacobian(gen_jac,a,&mm);    

    //variance of the moments
    ggg  = hac(mom(a))/nobs;         // HAC VCM of moment conditions
    
    //print One-step GMM
    if(i_onestep==1)
      {
      // variance-covariance matrix of sub-optimal GMM: wn=unit, s=ggg
      om     = invertsym(mm'mm)*mm'ggg*mm*invertsym(mm'mm)/nobs;     
      sterr  = sqrt(diagonal(om))';

      //print
      gmmprint( n_model , names_y , names_z , 0 , 0 , maxq , .NaN , .NaN , names , a , sterr , k , " ", i,Wprint);      

      //save residuals
      savemode  = savemode~0;
      mom(a);
      saveUvec = saveUvec~Uvec;

      break;
      }
       
    //variance-covariance matrix of parameters
    om     = invertsym(mm'wn*mm)/nobs;     
    sterr  = sqrt(diagonal(om))';          // standard errors of parameters
    jn     = -nobs*maxq;                   // J-test for over-identification
    pval   = tailchi(jn,k-rows(a));

    //print Two step GMM
    if(i==2 && i_twostep==1)
      {
      gmmprint( n_model , names_y , names_z , 1 , wmethod , maxq , jn , pval , names , a , sterr , k , kernname , i,Wprint);      

      //save residuals
      savemode  = savemode~1;
      mom(a);
      saveUvec = saveUvec~Uvec;

      break;
      }
      
    //criteria
    maxq0  = maxq0~maxq;
    change = fabs(maxq0[0][i]-maxq0[0][i-1]);

    //print iterated GMM
    if(change<=10^(-8) && i>=2)
      {
      gmmprint( n_model , names_y , names_z , 2 , wmethod , maxq , jn , pval , names , a , sterr , k , kernname, i ,Wprint);      

      //save residuals
      savemode  = savemode~2;
      mom(a);
      saveUvec = saveUvec~Uvec;

      break;
      }

    //print no convergence  
    if(i==maxiter && i_cu==0)
      {
      println("\n************************************");      
      println("* No convergence for               * ");
      println("* Iterated GMM in ",i," iterations    *");      
      println("************************************");
      }

    //update weight matrix
    wn     = invertsym(ggg);               // updated weighting matrix      
    }


  if(i_cu==1)
    {
    //continously updated GMM
    MaxBFGS(crit_cu, &a, &maxq, 0, 1);

    ggg    = hac(mom(a))/nobs;
    wn     = invertsym(ggg);

    //first derivaties
    NumJacobian(gen_jac,a,&mm);    
    
    //variance-covariance matrix of parameters
    om     = invertsym(mm'wn*mm)/nobs;
    sterr  = sqrt(diagonal(om))';
    jn     = -nobs*maxq;
    pval   = tailchi(jn,k-rows(a));

    //print
    gmmprint( n_model , names_y , names_z , 3 , wmethod , maxq , jn , pval , names , a , sterr , k , kernname );      

    //save residuals
    savemode  = savemode~3;
    mom(a);
    saveUvec = saveUvec~Uvec;   
    }

  if(wmethod==2 && kernelprint==1)
    {
    decl ll = min(int(bandw)+5,columns(kern)-1);
    println("\nKernel weights:","%#7.3f",1~kern[0][0:ll]);

    //graph
    SetDrawWindow("Kernel Weights");    
    DrawMatrix(0, reverser(kern[0][0:ll])~1~kern[0][0:ll],"Kernel Weigths", -ll-1,1,2);
    ShowDrawWindow();    
    }
                                  
  //residuals from final model  
  mom(a);
  savemat(oxfilename(1)+"Uvec.xlsx",savemode|saveUvec);

  J0 = jn[0][0];
  K0 = k;
  //fclose(filen);
  }



decl MAT,wnB;
//sample moment conditions
genCM(a)
  {
  return meanc( dropc(mom(a),MAT) )';
  }
//criteria function (conditional on the weights)
critCM(theta,adFunc,avScore,amHessian)
  {
  adFunc[0] = -genCM(theta)'wnB*genCM(theta);
  
  return 1;
  }
  
CMtestCore(pr,mat)
  {
  decl maxq,jn,b,maxqB,jnB;
  MAT=mat;      

  //optimization settings
  MaxControl(10000, 0, 0);
  MaxControlEps(1e-10, 1e-8);

  /////////////////////////
  //estimation: all moments
  //initial
  a      = zeros(rows(wn),1);

  //numerical optimization
  MaxBFGS(crit, &a, &maxq, 0, 1);

  //parameters and j-stat
  a     = deleteifr(a,a.==0);
  jn    = -nobs*maxq;

  /////////////////////////
  //estimation reduced moments
  //initial
  wnB = invert(dropr(dropc(invert(wn),mat),mat));
  b   = a;
  
  //numerical optimization
  MaxBFGS(critCM, &b, &maxqB, 0, 1);

  //paramters and j-stat
  //b     = deleteifr(b,b.==0);
  jnB   = -nobs*maxqB;

  //check
  if(fabs(jn-J0)<10^(-6))
    {
    decl TT = double(jn-jnB);
    decl kk = rows(wn)-rows(wnB);

    if(pr==1)
      {
      //estimates
      print("\n******************************************************************************\n");  
      println("%r",{"Test the validity of subsets of moment condition(s):  "},"%-3.0f",mat);
      println("%c",{"Full set","Reduced"},"%r",{"Moment conditions (R)"}~names~"J-stat","%cf",{"%16.4g","%16.4g"}, (rows(wn)|a|jn)~(rows(wnB)|b|jnB) );
      println("\nC-statistic:","%14.4g",TT," [","%5.3f",tailchi(TT,kk),"] in a Chi2(",kk,")\n");        
      //print("\n\nMEMO: Used weight matrices",wn,wnB);
      }
      
    return ( TT ~ tailchi(TT,kk) ~ kk);
    }
  else
    {
    if(pr==1)
      {
      print("\n******************************************************************************\n");  
      println("%r",{"Test the validity of subsets of moment condition(s):  "},"%-3.0f",mat);
      println("\nNo convergence..." );
      }
      
    return (.NaN ~ .NaN ~ rows(wn)-rows(wnB));
    }
  }

CMtest(mat)
  {
  if(i_onestep==1 || i_cu==1)
    {
    print("\nThe C-test for the validity of subsets of moment conditions\nis only implemented for two-step and iterative GMM...\n");
    }
  else
    {  
    decl k=rows(a);
    decl R=rows(wn);
    if(mat==<-1> && (R-k)>1)
      {
      //exclude all combinations of up to 3 moment conditions
      decl X = range(0,R-1)';
      decl exclude0 = {};
      decl exclude1 = {};
      for(decl i1=0;i1<rows(X);++i1)
        {
        exclude0 = exclude0~X[i1];
        if(R-k>1)
          {
          for(decl i2=i1+1;i2<rows(X);++i2)
            {
            exclude1 = exclude1~(X[i1]~X[i2]);
            //if(R-k>2)
            //  {
            //  for(decl i3=i2+1;i3<rows(X);++i3)
            //    {
            //    exclude = exclude~(X[i1]~X[i2]~X[i3]);
            //    }
            //  }  
            }
          }   
        }        
      decl exclude = exclude0~exclude1;  
      decl res = nans(rows(exclude),3);  
      for(decl i=0;i<rows(exclude);++i)
        {
        res[i][] = CMtestCore(0,matrix(exclude[i]));
        }
      decl H={};
      for(decl i=0;i<rows(exclude);++i)
        {
        H=H~replace(sprint("%4.0f",exclude[i]),"\n","");
        }
      print("\n******************************************************************************\nTest the validity of subsets of moment condition(s)\n\n");  
      print("   Excluded         Statistic    p-value    df");  
      print("%r",H,"%cf",{"%16.4g","    [%5.3f]","%6.3g"},res);    
      }
    else if( (R-k)>=1 && mat!=<-1> )
      {
      CMtestCore(1,mat);
      }
    }
  }
