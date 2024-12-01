#include <oxstd.oxh>
#import <packages/PcGive/pcgive>


// ------------------------------------------------
// Information:
//
// Add the following line to calculate
// impulse responses
// ------------------------------------------------
#include <ImpulseResponseCode.ox>


run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(25)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 4, 6});
	model.Select("Y", {"D4Inv", 8, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 4, 6});
	model.Select("Y", {"D4Q", 8, 9});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	return model;
}

main()
  {
  // ----------------------------
  // Replace "run_1();" with
  //         "decl m1 = run_1();"
  // ----------------------------    
  decl m1  = run_1();

  // ----------------------------
  // To calculate the impulse
  // responses add the following line
  // ----------------------------  
  decl res = ImpulseResponses(  m1,	  //model name
                               50,	  //number of steps
						   "unit",	  //type, choose "unit", "se", or "ortho"
						      TRUE,   //show graph, choose TRUE/FALSE
						      FALSE);  //show cumulated IR, choose TRUE/FALSE  
  }
