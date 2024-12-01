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
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.SetSelSample(1993, 2, 2022, 2);
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
	model.Select("X", {"dummy2009_1", 0, 0});
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
	model.Select("Y", {"D4log(GDP)", 1, 4});
	model.Select("X", {"dummy2009_1", 0, 0});
	model.SetSelSample(1993, 2, 2022, 2);
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
	model.SetSelSample(1993, 2, 2022, 2);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 6)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 1});
	model.Select("Y", {"D4log(GDP)", 4, 4});
	model.Select("X", {"I:2009(1)", 0, 0});
	// Formulation of the GUM (commented out)
/*
	model.DeSelect();
	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.Autometrics(0.01, "large", 1);
*/
	model.SetSelSample(1993, 2, 2009, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_6()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 7)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 5});
	model.Select("X", {"I:2009(1)", 0, 0});
	model.SetSelSample(1993, 2, 2009, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_7()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 8)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA1/Assignment_1.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4log(GDP)", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4log(GDP)", 1, 1});
	model.Select("Y", {"D4log(GDP)", 4, 4});
	model.Select("X", {"I:2009(1)", 0, 0});
	model.SetSelSample(1993, 2, 2009, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_8()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 9)
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
}
