#include <oxstd.oxh>
#import <packages/PcGive/pcgive_ects>
#import <packages/arfima/arfima>

// ------------------------------------------------
// Information:
//
// To use the PrintModels module
// Add the following 4 lines to import PrintModels
// ------------------------------------------------
#import <packages/PcGive/pcgive_ects>
#import <packages/PcGive/pcgive_garch>
#import <packages/arfima/arfima>
#import <PrintModels>


run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(12)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"dummy1993_3", 0, 0});
	model.Select("Y", {"dummy2000_1", 0, 0});
	model.Select("Y", {"dummy2006_4", 0, 0});
	model.Select("Y", {"D4Inv", 1, 13});
	model.Select("Y", {"D4Q", 1, 13});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	return model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(13)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"dummy1993_3", 0, 0});
	model.Select("Y", {"dummy2000_1", 0, 0});
	model.Select("Y", {"dummy2006_4", 0, 0});
	model.Select("Y", {"D4Inv", 1, 12});
	model.Select("Y", {"D4Q", 1, 12});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	return model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(14)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"dummy1993_3", 0, 0});
	model.Select("Y", {"dummy2000_1", 0, 0});
	model.Select("Y", {"dummy2006_4", 0, 0});
	model.Select("Y", {"D4Inv", 1, 11});
	model.Select("Y", {"D4Q", 1, 11});
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
  // run_1();
  // run_2();
  decl m1 = run_1();
  decl m2 = run_2();
  decl m3 = run_3();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();       // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1, m2, m3);             // Select models to print.
  printmodels.SetModelNames({"(I)","(II)","(III)"});   // Set the model names in the table.
  printmodels.SetPrintFormat(FALSE,TRUE,4,3); // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                   // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1,m2,m3;
  delete printmodels;
  }
