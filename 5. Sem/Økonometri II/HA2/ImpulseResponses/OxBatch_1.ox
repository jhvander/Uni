#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 1});
	model.Select("Y", {"D4log(GDP)", 4, 4});
	model.Select("X", {"dummy2009_1", 0, 0});
	model.SetSelSample(1993, 1, 2022, 2);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 2)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.Select("X", {"I:2009(1)", 0, 0});
	model.SetSelSample(1993, 2, 2022, 2);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_3()
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

	delete model;
}

run_4()
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
	model.Forecast(52);
	model.PrintForecasts();
	model.Forecast(42);
	model.PrintForecasts();
	model.Forecast(42);
	model.PrintForecasts();

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 6)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.SetModelClass("SYSTEM");
	// Formulation of the GUM (commented out)
/*
	model.DeSelect();
	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 13});
	model.Select("Y", {"D4Q", 1, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Autometrics(0.01, "large", 1);
*/
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_6()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 7)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 11});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_7()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 8)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 10});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_8()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 9)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 9});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_9()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(10)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 9});
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
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_10()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(11)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 8});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 8});
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

	delete model;
}

run_11()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(13)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.SetModelClass("SYSTEM");
	// Formulation of the GUM (commented out)
/*
	model.DeSelect();
	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 13});
	model.Select("Y", {"D4Q", 1, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Autometrics(0.01, "large", 1);
*/
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_12()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(14)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 9});
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
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_13()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(15)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 6});
	model.Select("Y", {"D4Inv", 8, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 6});
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
	model.TestRestrictions(<0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_14()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(16)
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
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_15()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(17)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 4, 5});
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
	model.TestRestrictions(<0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<1;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_16()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(18)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 4, 5});
	model.Select("Y", {"D4Inv", 8, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 4, 6});
	model.Select("Y", {"D4Q", 8, 9});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_17()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(19)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 4, 5});
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
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

run_18()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(20)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"I:1993(3)", 0, 0});
	model.Select("Y", {"I:2000(1)", 0, 0});
	model.Select("Y", {"I:2006(4)", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 4, 6});
	model.Select("Y", {"D4Inv", 8, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 4, 6});
	model.Select("Y", {"D4Q", 8, 9});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_19()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(21)
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
	model.Select("I", {"I:1993(3)", 0, 0});
	model.Select("I", {"I:2010(1)", 0, 0});
	model.Select("I", {"I:2006(4)", 0, 0});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_20()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(23)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 1});
	model.Select("Y", {"D4Inv", 3, 9});
	model.Select("Y", {"D4Q", 1, 1});
	model.Select("Y", {"D4Q", 3, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Select("X", {"I:1993(3)", 0, 0});
	model.Select("X", {"I:2000(1)", 0, 0});
	model.Select("X", {"I:2006(4)", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	// Formulation of the GUM (commented out)
/*
	model.DeSelect();
	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("Y", {"D4Q", 0, 0});
	model.Select("Y", {"D4Inv", 1, 13});
	model.Select("Y", {"D4Q", 1, 13});
	model.Select("U", {"Constant", 0, 0});
	model.Autometrics(0.01, "large", 1);
	model.AutometricsSet("stderr", "hcse");
*/
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_21()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(24)
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
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);
	model.TestRestrictions(<0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 1;
 1;
 1;
 1;
 1;
 1;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0;
 0 >);

	delete model;
}

main()
{
	run_1();
	run_2();
	run_3();
	run_4();
	run_5();
	run_6();
	run_7();
	run_8();
	run_9();
	run_10();
	run_11();
	run_12();
	run_13();
	run_14();
	run_15();
	run_16();
	run_17();
	run_18();
	run_19();
	run_20();
	run_21();
}
