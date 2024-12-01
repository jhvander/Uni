#include <oxstd.oxh>
#import <packages/PcGive/pcgive_garch>

run_1()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for VOL( 1)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Downloads/META.csv");
	model.Deterministic(-1);

	model.Select("Y", {"DlY", 0, 0});
	model.GARCH(1,1);
	model.SetSelSampleByDates(dayofcalendar(2012, 5, 21), dayofcalendar(2022, 12, 6));
	model.SetMethod("ML");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_2()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for VOL( 2)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Downloads/META.csv");
	model.Deterministic(-1);

	model.Select("Y", {"DlY", 0, 0});
	model.GARCH_t(1,1);
	model.SetSelSampleByDates(dayofcalendar(2012, 5, 21), dayofcalendar(2022, 12, 6));
	model.SetMethod("ML");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_3()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for VOL( 3)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Downloads/META.csv");
	model.Deterministic(-1);

	model.Select("Y", {"DlY", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"DlY", 1, 1});
	model.GARCH_t(1,1);
	model.SetSelSampleByDates(dayofcalendar(2012, 5, 22), dayofcalendar(2022, 12, 6));
	model.SetMethod("ML");
	model.Estimate();
	model.TestSummary();

	delete model;
}

run_4()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for VOL( 4)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Downloads/META.csv");
	model.Deterministic(-1);

	model.Select("Y", {"DlY", 0, 0});
	model.Select("X", {"Constant", 0, 0});
	model.Select("Y", {"DlY", 1, 1});
	model.EGARCH_GED(1,1);
	model.SetSelSampleByDates(dayofcalendar(2012, 5, 22), dayofcalendar(2022, 12, 6));
	model.SetMethod("ML");
	model.Estimate();

	delete model;
}

run_5()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for VOL( 1)
	decl model = new PcGiveGarch();

	model.Load("/Users/Japee/Documents/#University/5. Sem/Økonometri II/HA4/Data/Assignment_4.in7");
	model.Deterministic(-1);

	model.Select("HX", {"EMP", 0, 0});
	model.Select("HX", {"UNEMP", 0, 0});
	model.Select("HX", {"CPI", 0, 0});
	model.Select("HX", {"PMI", 0, 0});
	model.Select("HX", {"CONS", 0, 0});
	model.Select("Y", {"deltar", 0, 0});
	model.Select("X", {"EMP", 0, 0});
	model.Select("X", {"UNEMP", 0, 0});
	model.Select("X", {"CPI", 0, 0});
	model.Select("X", {"PMI", 0, 0});
	model.Select("X", {"CONS", 0, 0});
	model.EGARCH_GED(1,1);
	model.SetSelSampleByDates(dayofcalendar(1999, 1, 5), dayofcalendar(2018, 2, 16));
	model.SetMethod("ML");
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
}
