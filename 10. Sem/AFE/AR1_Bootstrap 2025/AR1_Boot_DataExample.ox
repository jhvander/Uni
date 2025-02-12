#include <oxstd.h>
#include <oxfloat.h>
#include <oxdraw.h>
#include <oxprob.h>

#include <AR1_Boot_Code.ox>


main()
  {
  format(800);

  //load data
  decl data = loadmat("Inflation.xlsx");
  decl x    = data[][1]';

  //show the data
  SetDrawWindow("Data");
  DrawTMatrix( 0 , x , "x" , 2000 , 1 , 12 , 0 , 2 );
  ShowDrawWindow();

  //estimation and testing
  ols_estimation( x , lag(x',1)'|ones(1,columns(x)) , TRUE );
  LR( x , 0.30 , TRUE);

  //different bootstrap tests
  //Bootstrap_LR( x , 0.30 , 399 , "iid"         , TRUE); //i.i.d. bootstrap
  //Bootstrap_LR( x , 0.30 , 399 , "normal"      , TRUE); //wild bootstrap med normal
  Bootstrap_LR( x , 0.30 , 399 , "rademacher"  , TRUE); //wild bootstrap med rademacher
  //Bootstrap_LR( x , 0.30 , 399 , "mammen"      , TRUE); //wild bootstrap med mammen
  //Bootstrap_LR( x , 0.30 , 399 , "permutation" , TRUE); //permutation test
  }