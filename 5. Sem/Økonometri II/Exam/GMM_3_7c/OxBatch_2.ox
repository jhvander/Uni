#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA3/Assignment_3-2.xls");
	model.Deterministic(-1);

	model.Select("Y", {"P", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"e", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(1918, 1, 2020, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 1)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 2)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_4()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 3)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 4)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_6()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 5)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_7()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 6)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_8()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 7)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_9()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 8)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_10()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ( 9)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(2, 1, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_11()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(10)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"z", 1, 6});
	model.SetSelSample(3, 2, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_12()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(11)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 6});
	model.SetSelSample(3, 3, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_13()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(12)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(3, 3, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_14()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(13)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Q.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"z", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"zlag", 0, 0});
	model.SetSelSample(3, 3, 2501, 4);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_15()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(14)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_16()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(15)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"ylag", 0, 0});
	model.SetSelSample(2, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_17()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(16)
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

	delete model;
}

run_18()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(17)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_avg.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"x", 0, 5});
	model.SetSelSample(6, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_19()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(19)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_avg.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"x", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"xlag", 0, 0});
	model.Select("X", {"I:63", 0, 0});
	model.Select("X", {"I:252", 0, 0});
	model.Select("X", {"I:255", 0, 0});
	model.Select("X", {"I:924", 0, 0});
	model.Select("X", {"I:1193", 0, 0});
	model.Select("X", {"I:1253", 0, 0});
	model.Select("X", {"I:1509", 0, 0});
	model.Select("X", {"I:1850", 0, 0});
	model.Select("X", {"I:1872", 0, 0});
	model.Select("X", {"I:1963", 0, 0});
	model.Select("X", {"I:2022", 0, 0});
	model.Select("X", {"I:2076", 0, 0});
	model.Select("X", {"I:2195", 0, 0});
	model.Select("X", {"I:2221", 0, 0});
	// Formulation of the GUM (commented out)
/*
	model.DeSelect();
	model.Select("Y", {"x", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"xlag", 0, 0});
	model.Autometrics(0.01, "large", 1);
*/
	model.SetSelSample(6, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_20()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(20)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_avg.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"x", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("X", {"xlag", 0, 0});
	model.SetRobustSEType(1);
	model.SetSelSample(6, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_21()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(21)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"y", 1, 15});
	model.SetSelSample(16, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_22()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(22)
	decl model = new PcGive();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/Exam/GMM_3_7c/Exam_Y_end.xlsx");
	model.Deterministic(-1);

	model.Select("Y", {"y", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"y", 1, 15});
	model.SetSelSample(16, 1, 2501, 1);
	model.SetMethod("OLS");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_23()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(23)
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

	delete model;
}

run_24()
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
	run_22();
	run_23();
	run_24();
}
