#include <oxstd.h>
#include <oxprob.h>
#include <oxdraw.h>
#import <solveqp>
#import <solvenle>

/*
ols_estimation(const pr,const ll,const hh)
MinimumVariance(const pr,const mu,const sigma,const mu_bar,const riskfree)
InverseMinimumVariance(const pr,const mu,const sigma,const var_bar,const riskfree)
MinimumVarianceNoShort(const pr,const mu,const sigma,const mu_bar,const riskfree)
DrawPortfolioChoice(const pr,const mu,const sigma,const mu_bar,const var_bar,const riskfree,const util,const noshort,const gname)
utility(const vP,const adFunc,const avScore,const amHessian)
foc(const avFunc,const vP)
*/

decl ksparam,n_param,df,btest,bpval;
decl ols_loglik;
decl ols_residual;
decl ols_para,ols_std,ols_tval,ols_omega,ols_covar;
//
//ols_estimation(pr,ll,hh)
//Unrestricted linear regression
//   pr       : (0/1)     print outpt or not
//   ll       :           matrix (m*T) of left hand side variables
//   hh       :           matrix (n*T) of right hand side variables
//
ols_estimation( pr , ll, hh)
  {
  decl i,text1,text2;
  decl xxpara,resi,s2,tval,r2;
  decl loglik;

  //names
  text1 = new array[columns(hh)];
  for(i=0;i<=columns(hh)-1;++i)
    {
    text1[i] = sprint("Var ",i+1);
    }
  text2 = new array[columns(ll)];
  for(i=0;i<=columns(ll)-1;++i)
    {
    text2[i] = sprint("Eq ",i+1);
    }

  //estimate    
  olsr(ll, hh, &ols_para, &xxpara);  
  ols_residual  = ll-ols_para*hh;
  ols_omega     = (1/columns(ll))*ols_residual*ols_residual';
  ols_covar     = xxpara**ols_omega;
  ols_std       = shape(diagonal(xxpara**ols_omega).^.5,rows(ll),rows(hh));
  ols_tval      = ols_para./ols_std;

  ols_loglik    = -0.5*columns(ll)*log(determinant(ols_omega));

  //print rows
  if(pr==1) print("\n\n************************************************************\n");
  if(pr==1) print("OLS estimation\n");
  if(pr==1) println("n      = ","%15.0f" ,columns(ll));
  if(pr==1) println("p      = ","%15.0f" ,rows(ll));
  if(pr==1) println("k      = ","%15.0f" ,rows(hh));
  if(pr==1) println("loglik = ","%#15.8f",ols_loglik[0][0]);
  if(pr==1) print("\nEstimates","%c",text1,"%r",text2,ols_para);
  if(pr==1) print("\nStd."     ,"%c",text1,"%r",text2,ols_std);
  if(pr==1) print("\nt-vals"   ,"%c",text1,"%r",text2,ols_tval);

  //if(pr==1) print("\nEstimates","%c",text2,"%r",text1,(ols_para|ols_std|ols_tval)');
  }


//  
//MinimumVariance( pr , mu , sigma , mu_bar , riskfree)
//solve minimum variance problem
//   pr       : print output or not
//   mu       : expected return
//   sigma    : covariance matrix
//   mu_bar   : given required return
//   riskfree : allow for risk free asset
//
MinimumVariance( pr , mu , sigma , mu_bar , riskfree)
  {
  decl v,ret,var,
       t_v=.NaN,t_ret=.NaN,t_var=.NaN,
       g_v=.NaN,g_ret=.NaN,g_var=.NaN;
       
  decl iota   = ones(rows(mu),1);
  decl isigma = invert(sigma);

  if(riskfree==.NaN)
    {
    decl a,b,c,D,phi0,phi1;
          
    a      = mu'isigma*mu;
    b      = mu'isigma*iota;
    c      = iota'isigma*iota;
    D      = b^2-a*c;

    phi0   = (b*isigma*mu-a*isigma*iota)/D;
    phi1   = (c*isigma*mu-b*isigma*iota)/D;

    //optimal weights
    v      = phi0-phi1*mu_bar;

    //portfolio variance
    ret    = v'mu;
    var    = v'sigma'v;

    //global minimum variance
    g_v    = (1/c)*isigma*iota;
    g_ret  = g_v'mu;
    g_var  = g_v'sigma'g_v;

    if(pr==1)
      {
      print("\n\nPortfolio choice without riskfree asset:\n");
      print("mu",mu);
      print("sigma",sigma);                        
      print("mu_bar",mu_bar);
      print("\ninverse sigma",isigma);                           
      print("a",a);
      print("b",b);
      print("c",c);
      print("D",D);
      print("phi0",phi0);
      print("phi1",phi1);
      print("v",v);
      }  
    }
  else
    {
    decl vf,t_vf;

    v  = 1/((mu-iota*riskfree)'isigma*(mu-iota*riskfree))*isigma*(mu-iota*riskfree)*(mu_bar-riskfree);
    var    = v'sigma'v;

    //riskfree weight
    vf = 1-sumc(v);
    v  = v|vf;
    //portfolio variance
    ret    = v'(mu|riskfree);

    //tangent portfolio
    t_v   = 1/(iota'(isigma*(mu-iota*riskfree)))*isigma*(mu-iota*riskfree);
    t_var = t_v'sigma't_v;
    t_ret = t_v'mu;

    if(pr==1)
      {
      print("\n\nPortfolio choice with riskfree asset:\n");
      print("mu",mu);
      print("mu_bar",mu_bar);
      print("\nsigma",sigma);                        
      print("v_q",t_v);
      print("v",v);
      }  
    }
    
  return {  v,  ret,  var,     //minimum variance
          g_v,g_ret,g_var,     //global minimum variance
          t_v,t_ret,t_var};    //tangent portfolio
  }

  
//  
//InverseMinimumVariance( pr , mu , sigma , var_bar , riskfree )
//solve the inverse minimum variance problem
//   pr       : print output or not
//   mu       : expected return
//   sigma    : covariance matrix
//   var_bar  : given required variance
//   riskfree : allow for risk free asset
//
InverseMinimumVariance( pr , mu , sigma , var_bar , riskfree )
  {
  decl rr,vv;
  decl help;
  decl i,ind;
  decl rmin,rmax;
  decl v_v=.NaN,v_ret=.NaN,v_var=.NaN;

  help = MinimumVariance(pr,mu,sigma,meanc(mu),riskfree);

  //construct axis
  if(isnan(riskfree)==1)  rmin = help[4];
  if(isnan(riskfree)==0)  rmin = riskfree;  
  rmax = 3*max(mu);

  rr = range(rmin,rmax,(rmax-rmin)/5000);

  vv=0*rr;
  for(i=0;i<=columns(rr)-1;++i)
    {
    vv[i] = MinimumVariance(0,mu,sigma,rr[i],riskfree)[2];
    }   
  ind  = mincindex((fabs(vv-var_bar)'));
  help = MinimumVariance(0,mu,sigma,rr[ind],riskfree);

  v_v   = help[0];
  v_ret = help[1];
  v_var = help[2];

  return {  v_v,  v_ret,  v_var};      //minimum variance given v
  }

  
//  
//MinimumVarianceNoShort( pr , mu , sigma , mu_bar , riskfree )
//solve minimum variance problem with shortselling disallowed
//   pr       : print output or not
//   mu       : expected return
//   sigma    : covariance matrix
//   mu_bar   : given required return
//   riskfree : allow for risk free asset
//
MinimumVarianceNoShort( pr , mu , sigma , mu_bar , riskfree )
  {
  decl iret,y,n,l;
  decl v,ret,var;

  n=rows(sigma);

  if(riskfree==.NaN)
    {
    //min y'Omega*y st. sum(y)=1, y'mu=mu_bar, y.>=0
    [iret,y,l] = SolveQP(sigma, zeros(n,1) , <>, <>,(ones(n,1)~mu)', 1|mu_bar, zeros(n,1), <>);
     //print("l=",l);
    
    if(iret==0)
      {
      v   = y;
      ret = y'mu;
      var = y'sigma*y;    
      }
    else
      {
      v   = .NaN*y;
      ret = .NaN;
      var = .NaN;
      }
    }
  else
    {
    [iret,y] = SolveQP(sigma, zeros(n,1) , -ones(n,1)', -1 ,(mu-riskfree)', mu_bar-riskfree, zeros(n,1), <>);
    if(iret==0)
      {
      v   = y;
      ret = riskfree+y'mu;
      var = y'sigma*y;
      }
    else
      {
      v   = .NaN*y;
      ret = .NaN;
      var = .NaN;
      }
    }
    
  return {  v,  ret,  var}; 
  }


decl mmmm,lambda;
//
//setlambda(ll)
//specify paramter of riskaversion
// ll    : parameter of riskaversion
//
setlambda(ll)
  {
  lambda = ll;
  }

  
//  
//DrawPortfolioChoice( pr , mu , sigma , mu_bar , var_bar , riskfree , util , noshort , gname)
//main function for drawing portfolio choice
//solve minimum variance problem
//   pr       : print output or not
//   mu       : expected return
//   sigma    : covariance matrix
//   mu_bar   : given required return
//   riskfree : allow for risk free asset
//   util     : draw also utility
//   noshort  : disallow shortsales
//   gname    : name of graphics window  
//
DrawPortfolioChoice( pr , mu , sigma , mu_bar , var_bar , riskfree , util , noshort , gname , date, mynames=.NaN)
  {
  decl rr,vv,vv2;
  decl help;
  decl rmin,rmax;
  decl v_gmv,r_gmv,s_gmv,v_required,r_required,s_required,v_requiredRf,r_requiredRf,s_requiredRf,v_tangent,r_tangent,s_tangent;

  SetDrawWindow(sprint("Portfolio_",gname));    
  //actual returns
  DrawXMatrix(0, mu',0,diagonal(sigma).^(.5),"Actual assets", 1, 4);

  if(isarray(mynames)==TRUE)
    {
    for(decl i=0;i<rows(mu);++i)
      {
      DrawText(0,mynames[i],diagonal(sigma)[i].^(.5),mu[i],-1,250);
      }
    }
  else
    {
    for(decl i=0;i<rows(mu);++i)
      {
      DrawText(0,sprint("Asset ",i+1),diagonal(sigma)[i].^(.5),mu[i],-1,250);
      }
    }
    
  //construct axis
  rmin = min(min(mu|(-0.25*max(mu))));
  rmax = 1.25*max(mu);

  help = MinimumVariance(0,mu,sigma,mu_bar,.NaN);
  rmin = min(rmin|help[1]|help[4]);
  rmax = max(rmax|1.25*help[1]|1.25*help[4]);

  //save for output
  v_required   = help[0];
  r_required   = help[1];
  s_required   = help[2];
  v_gmv        = help[3];
  r_gmv        = help[4];
  s_gmv        = help[5];
  v_tangent    = help[6];
  r_tangent    = help[7];
  s_tangent    = help[8];
  v_requiredRf = .NaN;
  r_requiredRf = .NaN;
  s_requiredRf = .NaN;

  if(isnan(riskfree)==0)
    {
    help = MinimumVariance(0,mu,sigma,mu_bar,riskfree);
    rmin = min(rmin|help[1]|help[7]);
    rmax = max(rmax|1.25*help[1]|1.25*help[7]);
    
    //save for output
    v_requiredRf = help[0][:rows(help[0])-2];
    r_requiredRf = help[1];
    s_requiredRf = help[2];
    v_tangent    = help[6];
    r_tangent    = help[7];
    s_tangent    = help[8];

    DrawXMatrix(0, riskfree,0,0.0,"Riskfree asset", 1, 8);
    }  
//rmin=-0.10;
//rmax= 0.70;
  rr = range(rmin,rmax,(rmax-rmin)/1000);
  
  //frontier, no riskfree asset
  vv = 0*rr;  
  for(decl i=0;i<=columns(rr)-1;++i)
    {
    help  = MinimumVariance(0,mu,sigma,rr[i],.NaN);
    vv[i] = help[2]^.5;

    }   
  DrawXMatrix(0, rr,0,vv,"Frontier", 0, 2);

  if(isnan(mu_bar)==0)
    {
    //Minimum variance portfolio
    help = MinimumVariance(0,mu,sigma,mu_bar,.NaN);
    //minimum variance, given return
    DrawXMatrix(0,  mu_bar,0,help[2].^.5,sprint("Minimum variance, $\\bar{\mu}=","%#3.3f",mu_bar,"$"), 1, 5);
    }
    
  //global minimum
  DrawXMatrix(0, help[4],0,help[5].^.5,"Global minimum variance", 1, 6);

  if(isnan(riskfree)==0)
    {
    //frontier, riskfree asset
    vv2 = 0*rr;
    for(decl i=0;i<=columns(rr)-1;++i)
      {
      help = MinimumVariance(0,mu,sigma,rr[i],riskfree);
      vv2[i] = help[2]^.5;  
      }
    DrawXMatrix(0, rr,0,vv2,"Frontier, risk-free asset", 0, 3);
  
    //including riskfree asset
    help = MinimumVariance(0,mu,sigma,mu_bar,riskfree);
    if(isnan(mu_bar)==0)
      {
      DrawXMatrix(0,  mu_bar,0,help[2].^.5,sprint("Minimum variance, $\\bar{\mu}=","%#3.3f",mu_bar,"$, risk-free asset"), 1, 7);
      }
    DrawXMatrix(0, help[7],0,help[8].^.5,"Tangent", 1, 8);
    }

  //minimum variance, given variance
  if(isnan(var_bar)==0)
    {
    help = InverseMinimumVariance(pr,mu,sigma,var_bar,riskfree);
    DrawXMatrix(0,  help[1],0,help[2].^.5,sprint("Minimum variance, $\\bar{\sigma^2}=","%#3.3f",sqrt(var_bar),"^2$"), 1, 5);
    }

  //decl util = 0;
  //decl k    = 6;
  decl k    = lambda;
  if(util==1)
    {
    decl fron,u,ui;
        
    //frontier portfolios
    if(isnan(riskfree)==0) fron = vv2;
    else                   fron = vv;

    //implied utility
    u    = rr-k*fron.^2;
    DrawXMatrix(0, rr,0,sqrt((3.00*max(u)-rr)/(-k)),0, 0, 4);
    DrawXMatrix(0, rr,0,sqrt((2.00*max(u)-rr)/(-k)),0, 0, 4);
    DrawXMatrix(0, rr,0,sqrt((1.50*max(u)-rr)/(-k)),0, 0, 4);
    DrawXMatrix(0, rr,0,sqrt((     max(u)-rr)/(-k)),0, 0, 4);
    DrawXMatrix(0, rr,0,sqrt((0.50*max(u)-rr)/(-k)),0, 0, 4);

    ui = maxcindex(u');
    DrawXMatrix(0, rr[ui],0,fron[ui],sprint("Utility maximization, $\\theta=","%#3.2f",k,"$"), 1, 4);
    mmmm = rr[ui];  
    }

  //decl noshort = 1;
  if(noshort==1)
    {
    decl vv3,vv4;

    //no risk-free
    vv3 = .NaN*rr;  
    for(decl i=0;i<=columns(rr)-1;++i)
      {
      help   = MinimumVarianceNoShort(0,mu,sigma,rr[i],.NaN);
      vv3[i] = help[2]^.5;
      }
    DrawXMatrix(0, rr,0,vv3,"Frontier with no short sale, no risk-free", 0, 1);

    if(isnan(riskfree)==0)
      {
      vv4 = .NaN*rr;  
      for(decl i=0;i<=columns(rr)-1;++i)
        {
        help   = MinimumVarianceNoShort(0,mu,sigma,rr[i],riskfree);

        vv4[i] = help[2]^.5;
        }
      DrawXMatrix(0, rr,0,vv4,"Frontier with no short sale, risk-free rate", 0, 9);
      }
    }


	DrawTitle(0, date);
  ShowDrawWindow();

  return {"Required return"        ,v_required,r_required,s_required,
          "Global minimum variance",v_gmv,r_gmv,s_gmv,
          "Required with risk free",v_requiredRf,r_requiredRf,s_requiredRf,
          "Tangent"                ,v_tangent,r_tangent,s_tangent};
  }

decl returndata;  
decl util,pp,rr;
utility( vP , adFunc , avScore , amHessian )
  {
  decl uu,mu;

  //calculate return;
  pp      = vP|(1-sumc(vP));
  rr      = pp'returndata;
  //lambda  = 6;

  //mean variance utility;
  if(util==0)
    {    
    mu      = meanr((1+rr))-0.5*lambda*meanr(((rr)-meanr(rr)).^2);
    }
  //negative exponential CARA 
  if(util==1)
    {
    uu      = -exp(-lambda*(1+rr));
    mu      = meanr(uu);
    if(avScore)
      {      
      avScore[0] = meanr(  -exp(-lambda*(1+rr)).*(-lambda*(returndata[0:rows(vP)-1][]-returndata[rows(vP)][]))  );
      }
    }
  //power, CRRA  
  if(util==2)
    {
    uu      = ((3+rr).^(1-lambda))/(1-lambda);
    mu      = meanr(uu);
    }
  //log
  if(util==3)
    {
    uu      = log(1+rr);
    mu      = meanr(uu);
    }

  adFunc[0] = double(mu);  
  return 1;
  }

foc( avFunc , vP )
  {
  decl uu,mu;

  //calculate return;
  pp      = vP|(1-sumc(vP));
  rr      = pp'returndata;

  if(util==1)
    {
    avFunc[0] = meanr(  -exp(-lambda*(1+rr)).*(-lambda*(returndata[0:rows(vP)-1][]-returndata[rows(vP)][]))  );
    }
  if(util==2)
    {
    avFunc[0] = meanr(  ((3+rr).^(-lambda)).*(returndata[0:rows(vP)-1][]-returndata[rows(vP)][]) );
    }
    
  return 1;
  }

NytteMax( mu0 , sigma0 , NoShort , steps=500 , gamma=1 , riskfree=.NaN )
  {
  decl mu,sigma,v,var,nytte,list,result,ind,out;
  decl mini,maxi;

 
  mini = min(mu0|riskfree);
  if(riskfree==.NaN)
    {
    maxi = max(mu0|riskfree);
    }
  else
    {
    maxi = max(2*mu0|riskfree);
    }

  list   = range( mini ,maxi,(maxi-mini)/steps)';
  result = nans(rows(list),3+rows(mu0));

  decl i,ret;
  foreach(ret in list[i])
    {
    if(NoShort==TRUE)
      {
      out   = MinimumVarianceNoShort( FALSE, mu0, sigma0,  ret , riskfree);
      }
    else
      {
      out   = MinimumVariance( FALSE, mu0, sigma0,  ret , riskfree);
      }
      
    v     = out[0];
    mu    = out[1];
    var   = out[2];
    nytte = mu - gamma*var;

    result[i][]  = mu~var~nytte~v';
    //print(mu~var~nytte);
    } 

  ind   = maxcindex(result[][2]);
  mu    = result[ind][0];
  var   = result[ind][1];
  nytte = result[ind][2];
  v     = result[ind][3:]';  
  //print(result," ",mu," ",var," ",nytte,v);

  if(riskfree!=.NaN && NoShort==TRUE)
    {
    v = deleter(v);
    v = v|(1-sumc(v));
    }

  return deleter(v);
    
  }
  