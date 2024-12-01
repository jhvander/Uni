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
}
