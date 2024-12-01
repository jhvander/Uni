#include <oxstd.oxh>
#include <oxdraw.oxh>
#import <maximize>

//
//construct the duplicator matrix D for dimension m
//such that vec(A) = D*vech(A)
duplicator(const m)
  {
  decl mat,ind,i,j,tal;

  //constructs the elimination matrix
  //ind = vec(lower(ones(m,m)));
  //mat = deleteifr(unit(m*m),1-ind);
  
  //constructs the duplication  matrix
  mat = zeros(m*m,m*(m+1)/2);
  ind = vec(unvech(range(1,m*(m+1)/2)))-1;
  for(i=0;i<=m*m-1;++i)
    {
    mat[i][ind[i]] = 1;
    }
    
  return mat;
  }

//
//calculate the impulse responses
decl asY,asX,step,IRtype,isAcc;
decl aC;
GetMA( IR , bigpi )
  {
  decl p,pi,PI,maxlag,omega;
  decl compan,B0,C,ma;
 
  //constants and placeholders
  p      = rows(asY);
  PI     = {nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p),nans(p,p)};
  maxlag = 0;

  //sort coefficients
  pi     =         bigpi[0:rows(bigpi)-p*(p+1)/2-1];
  omega	 = unvech( bigpi[rows(bigpi)-p*(p+1)/2:] );

  //loop over rows
  for(decl j=0;j<p;++j)
    {
    decl y  = asY[j] ;

	//loop over endogenous variables
    for(decl k=0;k<p;++k)
      {
	  //regressor
      decl x  = asY[k];

      //loop for coefficients
	  for(decl i=0;i<rows(asX);++i)
        {
	    decl xx  = asX[i][0:strfind(asX[i],"@")-1];		
        decl in  = asX[i][strfind(asX[i],"@")+1:];

		decl o   = strifindr(xx,"_");
		
		if(o>-1)
		  {
		  decl xxx = xx[:o-1] ;

		  if(x==xxx && y==in)
	        {
		    decl lag;
		    sscan( xx[strifindr(xx,"_")+1:] , &lag );

			//autoregressive coefficient
 		    PI[lag-1][j][k] = pi[i];
			maxlag = max(maxlag,lag);
		    }
		  }
        }
	  }
	}
	
  //construct companion matrix
  compan = PI[0];
  for(decl i=1;i<maxlag;++i)
    {
    compan ~=PI[i];
	}
  compan = replace(compan,.NaN,0)|(unit(p*(maxlag-1))~zeros(p*(maxlag-1),p));

  //type of IR function
  if(IRtype=="unit")
    {
    //unit shocks
	B0 = unit(p);
	}
  else if(IRtype=="se")
    {
    //standard errors
	B0 = diag(sqrt(diagonal(omega)));  
	}
  else if(IRtype=="ortho")
    {
    B0 = choleski(omega);	
	}
  else
    {
	print("\n\n\nchoose type uni/se/orthogonal...\n\n\n");
	return;
	}
	
  //impulse responses
  C  = unit(rows(compan));
  aC = {C[0:p-1][0:p-1]*B0};
  ma = vec(C[0:p-1][0:p-1]*B0);
  for(decl k=1;k<step;++k)
    {
	C   = C*compan;
    aC ~= {C[0:p-1][0:p-1]*B0};
	ma ~= vec(C[0:p-1][0:p-1]*B0);
	}

  //calculate accumulated IR
  if(isAcc==TRUE)
    {
	ma = cumulate( ma' )';
	}
	
  //return as a vector	
  IR[0] = vec(ma');

  return 1;
  }

//
//main function
ImpulseResponses( model , steps=50 , type="unit" , graph=TRUE , acc=FALSE )
  {
  decl pi,asW,varpi,varMA,omega,p,n;
  decl bigpi,varbigpi, ma,Jac;
  decl dupbar,varomega;

  //global variables
  step   = steps;
  IRtype = type;
  isAcc  = acc;

  //model information for IR
  model.GetVarNames(&asY, &asW);
  pi       = model.GetPar();
  varpi    = model.GetVarRf();
  asX      = model.GetParNames();
  omega    = model.GetOmega();
  p        = rows(omega);
  n        = model.GetcT();

  //include also variances as parameters
  dupbar   = invert(duplicator(p)'duplicator(p))*duplicator(p)';
  varomega = 2*(1/n)*dupbar*(omega**omega)*dupbar';
  bigpi    = pi|vech(omega);
  varbigpi = diagcat(varpi,varomega);
  
  //calculate IR and variances
  GetMA(&ma,bigpi);
  NumJacobian(GetMA,bigpi, &Jac);
  varMA = diagonal(Jac*varbigpi*Jac' )';

  //convert to matrix
  ma    = shape(   ma,rows(varMA)/(rows(asY)^2),rows(asY)^2)';
  varMA = shape(varMA,rows(varMA)/(rows(asY)^2),rows(asY)^2)';

  //draw graphs
  if(graph==TRUE)
    {
	//construct legend
    decl title = {};
    for(decl i=0;i<rows(asY);++i)
      {
      for(decl j=0;j<rows(asY);++j)
        {
		if(acc==TRUE)
		  {
	      title ~= sprint("cum. ",asY[j]," (",asY[i]," eq.)");
		  }
		else
		  {
	      title ~= sprint(asY[j]," (",asY[i]," eq.)");
		  }		
	    }
	  }  

	for(decl i=0;i<rows(ma);++i)
      {
      DrawTMatrix(i,ma[i][],title[i],1,1);
      DrawZ(sqrt(varMA[i][]),0,ZMODE_FAN);
      //DrawTMatrix(i,ma[i][]+2*sqrt(varMA[i][]),0,1,1);
      //DrawTMatrix(i,ma[i][]-2*sqrt(varMA[i][]),0,1,1);
	  }
    ShowDrawWindow();
	}

  //calculates the forecast error variance decomposition	
  if(type=="ortho")
    {
	print("\n**************************************");
	print("\nForecast error variance decomposition:\n");
	decl a;	
    GetMA(&a,bigpi);

	decl FEV = { aC[0].*aC[0] };
	for(decl s=1;s<steps;++s)
	  {
	  FEV ~= FEV[s-1] + aC[s].*aC[s];
	  }
	for(decl i=0;i<p;++i)
	  {
	  print("\nFEVD for ",asY[i]);
	  decl temp = <>;
	  for(decl s=0;s<steps;++s)
	    {
	    temp |= (s ~ 100*(FEV[s][i][] ./ sumr(FEV[s][i][])));
		}
	  print("%c",{"Horizon"}~asY,temp);	
	  }
//	print(aC[0]*aC[0]',omega);
	
	}
	
  //return results
  return {ma,varMA};
  }