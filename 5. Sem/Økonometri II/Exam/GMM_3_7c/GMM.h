#ifndef GMM_INCLUDED
#define GMM_INCLUDED

#import <maximize>
#import <modelbase>


enum // variable types
{   Y_VAR, I_VAR, i_VAR
};
enum // estimation types
{   M_TWOSTEP, M_ITERATED, M_CU
};
enum // model classes
{   MC_GMM
};


/*-------------------------- GMM : Bprobit -----------------------------*/
class GMM : Modelbase
  {
    decl Y,Z,a;
	decl Uvec,Gmat;
	decl im,inam;
	decl m_iModel;								    /* current model number */
	decl m_iModelClass;
	decl m_mW;								   /* weight variable [m_cT][1] */
	decl m_cW;					      /* number of weight variables, 0 or 1 */
	decl m_mSel;							   /* sample selection variable */
	decl m_cSel;
	decl m_mIdx;	/* observation index (in database) of estimation sample */
	decl m_fCovarUnweighted;		  /* TRUE: unweighted covariance matrix */
	decl m_asY, m_asX, m_asW, m_asSel;							   /* names */
	decl s_code,s_sample,s_message,s_inicode,s_inicode_l,s_help,islinear,SetInitialW;
	decl issubset,subset,allsubset;

    //declare global variables
    decl adFunc,genval,avScore,amHessian,wn,nobs;
    decl kernel,indik,wmethod,emethod,kernname,kern,manualband,wconst,bandw;
    decl i_method,i_onestep,i_twostep,i_iterated,i_cu,kernelprint,PrintFinalW,Uvecprint,maxit,isauto,n_model,oxpath,oxpath0,oxpath1;

	decl samp_set,samp_start,samp_end;
    GMM();
	
    Get_Y();
    TranslateToOxCode(A);
	IsIn(a,B);
	fprintmat( filen, mmat , ddec);
	
	virtual GetPackageName();
	virtual GetPackageVersion();
	virtual GetParNames();
    virtual InitData();                       /* extract data from database */
    virtual InitPar();             // initialize parameters
    virtual DoEstimation(vP);		                   /* do the estimation */
    virtual Covar();  // compute variance-covariance matrix
	virtual Output();

	// OxPack related
	virtual Buffering(const bBufferOn);
	virtual GetMethodLabel();
	virtual GetModelLabel();
	virtual GetModelSettings();
	virtual LoadOptions();
	virtual ReceiveDialog(const sDialog, const asOptions, const aValues);
	virtual ReceiveModel();
	virtual SaveOptions();
	virtual DoOption(const sOpt, const val);
	virtual DoGraphicsDlg();
	virtual ReceiveMenuChoice(const sDialog);
	virtual SendMenu(const sMenu);
	virtual IsCrossSection();
	virtual SendSpecials();
	virtual SendVarStatus();
	virtual SetModelSettings(const aValues);
	virtual BatchCommands();
	virtual BatchMethod(const sMethod);
	virtual DoOxPackDialog();
};

#endif
