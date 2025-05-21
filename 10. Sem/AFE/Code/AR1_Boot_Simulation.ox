#include <oxstd.h>
#include <oxfloat.h>
#include <oxdraw.h>
#include <oxprob.h>

#include <AR1_Boot_Code.ox>


main()
  {
  format(800);

  decl n,nmat,delta,rho,b,iter;
  decl Res,y,lr,pval,z_tilde,theta_tilde,theta_hat,Bpval;
  
  ///////////////////
  nmat    =   <25>;  //matrix with different sample length, e.g. <15,25,50,100,250,500,1000>;
  delta   =     0;	 //constant term
  rho     =   0.9;	 //autoregressive coefficient
  b       =   0.9; 	 //hypothesis H0:rho=b
  iter    =  1000;	 //monte carlo replications
  ///////////////////

  print("\nEmpirical rejection frequencies:");

  //loop over different sample lengths
  foreach(decl n in nmat)
    {
	//placeholder for results
    Res = nans(iter,5);

	//monte carlo loop
    parallel for( decl i=0 ; i<iter ; ++i )
      {
      //generate data
      y = Generate( delta , rho , delta/(1-rho) , rann(1,n) );

      //LR test
      [ lr , pval , z_tilde , theta_tilde , theta_hat ] = LR( y , b );

	  //bootstrap test    
	  [ Bpval ] = Bootstrap_LR( y , b , 399 , "iid" );

	  //collect results
      Res[i][0:4]  = theta_hat ~ lr ~ pval ~ Bpval;
      }
    
    //print("\nAll results:","%c",{"rho_hat","delta_hat","LR","p-val","Bootstrap"},Res);  
    print("%c",{"n","rho","b","Asymptotic","Bootstrap"},n~rho~b~meanc(Res[][3:4].<=0.05));
	}

//  DrawTMatrix(0,y,"y");
//  DrawDensity(1,Res[][0]',"theta_hat",1,1,1,0);
//  ShowDrawWindow();

  }