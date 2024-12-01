#include <oxstd.oxh>
#import <packages/PcGive/pcgive>

main()
{
// This program requires a licenced version of PcGive Professional.
	//--- Ox code for EQ(15)
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
