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
	//--- Ox code for EQ( 2)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.SetSelSample(1993, 2, 2009, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	return model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 3)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.Select("X", {"dummy2009_1", 0, 0});
	model.SetSelSample(1993, 2, 2009, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	return model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 4)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 1});
	model.Select("Y", {"D4log(GDP)", 4, 4});
	model.Select("X", {"dummy2009_1", 0, 0});
	model.SetSelSample(1993, 2, 2009, 1);
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
