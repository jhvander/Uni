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
	//--- Ox code for EQ(24)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_avg.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"x", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"xlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
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

  // ----------------------------
  // Use the PrintModels class by
  // adding the following lines.
  // ----------------------------
  decl printmodels = new PrintModels();       // Creates a new class object called "printmodels", which we use to print results of the estimated models we add in the next line.
  printmodels.AddModels(m1);             // Select models to print.
  printmodels.SetModelNames({"(y-average)"});   // Set the model names in the table.
  printmodels.SetPrintFormat(FALSE,TRUE,4,3); // Print format: Use SE , use scientific notation, precision of estimates, precision of standard errors/t-values
  printmodels.PrintTable();                   // Produce tex-table.

  // ------------------------------
  // Delete everything from memory.
  // ------------------------------
  delete m1;
  delete printmodels;
  }
