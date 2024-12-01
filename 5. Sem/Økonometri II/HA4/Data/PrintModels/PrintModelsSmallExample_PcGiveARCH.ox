#include <oxstd.oxh>
#import <packages/PcGive/pcgive_garch>

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
	//--- Ox code for VOL( 3)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA4/Data/Assignment_4.in7");
	model.Deterministic(-1);

	model.Select("HX", {"EMP", 0, 0});
	model.Select("HX", {"UNEMP", 0, 0});
	model.Select("HX", {"CPI", 0, 0});
	model.Select("HX", {"PMI", 0, 0});
	model.Select("HX", {"CONS", 0, 0});
	model.Select("HX", {"Constant", 0, 0});
	model.Select("Y", {"deltar", 0, 0});
	model.Select("X", {"EMP", 0, 0});
	model.Select("X", {"UNEMP", 0, 0});
	model.Select("X", {"CPI", 0, 0});
	model.Select("X", {"PMI", 0, 0});
	model.Select("X", {"CONS", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.EGARCH_GED(1,1);
	model.SetSelSampleByDates(dayofcalendar(1999, 1, 5), dayofcalendar(2018, 2, 16));
	model.SetMethod("ML");
	model.Estimate();

	return model;
}

main()
  {
  // ----------------------------
  // Replace "run_1();" with
  //         "decl m1 = run_1();"
  // ----------------------------
  decl m1 = run_1();

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();                    // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1);                  // Select models to print.
  printmodels.SetModelNames({"EGARCH(1,1)"}); // Set the model names in the table.
  printmodels.SetPrintFormat(TRUE, TRUE, 4, 3);            // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                                // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1;
  delete printmodels;
  }
