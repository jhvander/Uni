#include <oxstd.h>
#include <oxdraw.h>
#include <PortfolioChoiceProcedures_modified.ox>

MyPortfolioWeights(mu,omega,C_0,lambda)
{
	decl invOmega, iota, delta;
	invOmega = invert(omega);
	iota = ones(rows(mu),1);
	delta = (mu' * invOmega * iota - lambda * C_0) / (iota' * invOmega * iota);
	
	return invOmega * (mu - delta * iota) / lambda;
}

MyUtility(v, mu, Omega, C_0, lambda)
{
	decl EC_t, VC_t;
	EC_t = C_0 + v' * mu;
	VC_t = v' * Omega * v;

	return (EC_t - lambda * 0.5 * VC_t)[0]; 
}


main() 
  {
  decl mu,omega,names;
 

  //specify estimated mean
  mu    = <0.00029479331295202346;0.0009207918280824592;0.0010223379978462257>;
									   		

  //specify estimated dynamic covariance. Here I use unvech() to avoid writing the numbers twice :)
  omega = unvech(<0.0004564067917286964,0.00013753759941615356,9.428194814124556e-5,
                             0.0006794118042876453,0.00011962487428757543,
                                   0.00015913280795477858>);
																								
								
	 					

 names = {"Danske Bank","GN","DSV"};
 
  //syntax:
  //DrawPortfolioChoice(pr, mu, omega, mu_bar, var_bar, riskfree, util, noshort,gname,date ,names)
  decl date = "2019-03-01";
  decl v = DrawPortfolioChoice( 1, mu, omega,   .NaN,    .NaN,     .NaN,    0,     FALSE,"case_1",date, names);

  // Accesing GMV weights
  decl v_gmv = v[5];

  // Calculating portfolio weights from utility maximization
  decl C_0 = 1.0;
  decl lambda = 1.0;
  decl v_u = MyPortfolioWeights(mu,omega, C_0, lambda);

  // See output file
  print("The GMV-weights are",v_gmv',"\n");
  print("The u-max-weights are",v_u',"\n");

  // Calculate utility
  decl util_u, util_gmv;
  util_gmv = MyUtility(v_gmv, mu, omega, C_0, lambda);
  util_u = MyUtility(v_u, mu, omega, C_0, lambda);

  // See output file
  print("The utility from using the GMV-weights is ",util_gmv,"\n");
  print("The utility from using the u-max-weights is ",util_u,"\n");
  
  }
