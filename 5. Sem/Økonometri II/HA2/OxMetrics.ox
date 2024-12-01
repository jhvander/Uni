#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA2/Assignment_2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"D4Inv", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"D4Inv", 1, 13});
	model.Select("X", {"D4Q", 0, 13});
	model.Select("X", {"dummy1993_3", 0, 0});
	model.Select("X", {"dummy2000_1", 0, 0});
	model.Select("X", {"dummy2006_4", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 2)
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
 1;
 1;
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

	delete model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 3)
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
 1;
 1;
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

	delete model;
}

run_4()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 4)
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

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 5)
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
	model.Select("Y", {"D4Inv", 12, 13});
	model.Select("Y", {"D4Q", 12, 13});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_6()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 6)
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
	model.Select("Y", {"D4Inv", 12, 12});
	model.Select("Y", {"D4Q", 12, 12});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_7()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 7)
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

	delete model;
}

run_8()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 8)
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
	model.Select("Y", {"D4Inv", 12, 13});
	model.Select("Y", {"D4Q", 12, 13});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_9()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS( 9)
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
	model.Select("Y", {"D4Inv", 12, 12});
	model.Select("Y", {"D4Q", 12, 13});
	model.Select("Y", {"D4Inv", 13, 13});
	model.Select("U", {"Constant", 0, 0});
	model.SetModelClass("SYSTEM");
	model.SetRobustSEType(1);
	model.SetSelSample(1975, 3, 2019, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_10()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for SYS(10)
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
	model.Select("Y", {"D4Inv", 12, 12});
	model.Select("Y", {"D4Q", 12, 12});
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
	//--- Ox code for SYS(11)
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

	delete model;
}

run_12()
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

	delete model;
}

run_13()
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

	delete model;
}

run_14()
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
}
