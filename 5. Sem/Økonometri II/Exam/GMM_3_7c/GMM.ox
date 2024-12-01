#include <oxstd.h>
#include <oxdraw.h>
#include <oxfloat.h>
#include <oxprob.h>
#include "GMM.h"

GMM::GMM()
  {
  //paths no longer needed
  //oxpath  = "c:\\program files\\oxmetrics7\\ox\\bin64"; // location for oxrun.exe
  //oxpath0 = "z:\\Teaching\\EconometricsC\\GMM";         // location for GMM module

  // initialize base class
  Modelbase();
  SetSelSampleMode(SAM_ALLVALID);
  samp_set = 0;
  
  im = 0;

  //initial values
  n_model     = 1;
  i_method    = 2;
  i_onestep   = 0;
  i_twostep   = 0;
  i_iterated  = 0;
  i_cu        = 0;
  manualband  = 0;
  wmethod     = 1;
  kernel      = 0;  
  kernelprint = 1;
  PrintFinalW = 0;
  //Uvecprint  = 0;
  maxit       = 500;
  islinear    = 1;
  SetInitialW = 0;
  issubset    = 0;
  subset      = <>;
  allsubset   = 0;
  
  // print startup message
  println("---- ", GetPackageName(), " ", GetPackageVersion()," session started at ", time(), " on ", date(), " ----");  
  }
  
GMM::GetPackageName()
  {
  return "GMM";
  }
  
GMM::GetPackageVersion()
  {
  return "3.7c (C) Heino Bohn Nielsen";
  //
  // Revision history:
  //
  // 2022/12/14, 3.7c : update to work with Ox 9.
  // 2018/08/27, 3.7b : small reformulation of OxPackOxRun for Ox 8.
  // 2017/04/12, 3.7  : small bug-fix in counting parameters.
  // 2017/02/03, 3.6b : made initial values non-zero.
  // 2016/12/12, 3.6  : made sample-selection persistent and changed model information.
  // 2016/07/01, 3.5  : implemented test of subsets of moment conditions.
  // 2016/06/23, 3.4  : only one estimation method per round. changes to organization of output.
  // 2016/06/22, 3.3  : added help file.
  // 2016/06/16, 3.2  : changed parameter names from a[] to {} and default selection type.
  // 2016/06/14, 3.1  : changed default variable selection type, allow linear GMM without code window and improved "store residuals".
  // 2016/06/14, 3.0  : changed from systemcall() to OxPackOxRun.
  //
  // Heino Bohn Nielsen
  // University of Copenhagen  
  }


//control that a text is in an array
GMM::IsIn(a,B)
  {
  decl is=-1;

  for(decl i=0;i<rows(B);++i)
    {
    if(a==B[i])
      {
      is=i;
      break;
      }
    }

  return is;
  }

//translate {} to A[] for readable ox-code  
GMM::TranslateToOxCode(A)
  {
  decl AA,a,b,c,par,isin;

  //empty arrays
  par = {};

  //find parameters in code
  AA=A;
  for(decl i=0;i<100;++i)
    {
    //find variable
    a = strfind(AA,"{");
    //if it exists
    if(a>-1)
      {
      b = strfind(AA,"}");
      c = AA[a+1:b-1];
      //check that it is there already
      isin = 0;
      for(decl j=0;j<rows(par);++j)
        {
        if(par[j]==c)
          {
          isin = 1;
          }
        }
      if(isin==0)
        {
        par = par|c;
        }
      AA = AA[b+1:];    
      }
    else
      {
      break;
      }
    }  

  //replace
  AA=A;
  for(decl i=0;i<rows(par);++i)
    {
    AA = replace(AA,sprint("{"+par[i]+"}"),sprint("a[",i,"]"));
    }

  return {AA,par};  
  }

  
GMM::SendMenu(const sMenu)
  {
  switch_single (sMenu)
    {
    case "ModelClass":
      return {{ "&1: GMM Estimation", "modelclass0",m_iModelClass == MC_GMM}};
    case "Model":
      //return 
      //{  { "Formulate...",               "OP_FORMULATE"},
      //   0,
      //   { "Settings...",                "OP_DIALOG"}
      //};
      return  { { "&Formulate\tAlt+Y", "OP_FORMULATE"},
                { "Model &Settings\tAlt+S", "OP_SETTINGS"},
                { "&Estimate\tAlt+L", "OP_ESTIMATE"},
                { "St&ore Residuals in Database\tAlt+O", "OP_STORE"} };
      //return Modelbase::SendMenu(sMenu);
      //case "Test":
      // return {{ "&Graphic Analysis...", m_iModelClass == MC_GMM ? "" : "OP_TEST_GRAPHICS"},
      //          0,
      //          { "&Further Output...", "Further Output"},
      //          0,
      //          { "Store in D&atabase...", "OP_TEST_STORE"}
      //          };
    }
  }

GMM::ReceiveMenuChoice(const sDialog)
  {
  switch_single (sDialog)
    {
    case "modelclass0":
      m_iModelClass = MC_GMM;
      return 1;
    case "OP_FORMULATE":
      if (DoFormulateDlg(2,0)) "OxPackSendMenuChoice"("OP_ESTIMATE");

      //if(DoFormulateDlg(2,0)==1)
      //  {
      //  //ReceiveData();
      //  ReceiveModel();
      //  DoEstimateDlg(0, 3, "2-Step efficient|Iterated|Continously updated", FALSE, FALSE, FALSE);
      //  }
      return 1;
    case "OP_ESTIMATE":
      DoOxPackDialog();
      return DoEstimateDlg(0, 0, 0, FALSE, FALSE, FALSE);
      //return DoEstimateDlg(0, 2, "GMM|Continously updated", FALSE, FALSE, FALSE);
      //case "OP_ESTIMATE":
      //  return DoEstimateDlg(0, 3, "2-Step efficient|Iterated|Continously updated", FALSE, FALSE, FALSE);
      //case "OP_OPTIONS":
      //  {
      //  // append GMM options to the Modelbase ones
      // decl adlg =
      //   {   { "Further options", CTL_GROUP, 1 },
      //       { "Use unweighted covariance matrix",
      //               CTL_CHECK, m_fCovarUnweighted, "covunw" }
     //       };
      // return 1;//DoOptionsDlg(adlg);
      // }
    case "OP_STORE":
      decl HH    = loadmat(oxfilename(1)+"Uvec.xlsx");
      decl Uvec  = HH[1:][];
      decl CC    = HH[0][];
      decl name  = {};
      for(decl i=0;i<columns(CC);++i)
        {
        if(CC[i]==0)
          {
          name = name~sprint("Uvec","_1S","_M",n_model-1);
          }
        if(CC[i]==1)
          {
          name = name~sprint("Uvec","_2S","_M",n_model-1);
          }
        if(CC[i]==2)
          {
          name = name~sprint("Uvec","_IT","_M",n_model-1);
          }
        if(CC[i]==3)
          {
          name = name~sprint("Uvec","_CU","_M",n_model-1);
          }
        }
      //decl name  = sprint("Uvec_",n_model-1);
      for(decl i=0;i<columns(Uvec);++i)
        {
        "OxPackStore"(Uvec[][i],samp_start,samp_end,name[i],TRUE);
        }
      return 1;
    case "OP_TEST_GRAPHICS":
      return DoGraphicsDlg();
    case "Further Output":
      return 0;
    default:
      // allow base class to process unhandled cases
      return Modelbase::ReceiveMenuChoice(sDialog);
    }
  }

GMM::DoOxPackDialog()
  {
  decl adlg, asoptions, avalues;

  //reset
  if(manualband==0)
    {
    isauto     = 1;
    manualband = 12;
    }
  else
    {
    isauto     = 0;
    }
  //issubset=0;  
  //subset=<>;  
    
  adlg =
    {   { "Estimators:"                              , CTL_GROUP, 1 },    
        { "One-Step GMM"                             , CTL_RADIO, i_method    ,"method" },
        { "Two-Step Efficient GMM"                   , CTL_RADIO },
        { "Iterated GMM"                             , CTL_RADIO },
        { "Continously Updated GMM"                  , CTL_RADIO },    
      //{ "One-Step GMM"                             , CTL_CHECK, i_onestep  , "one-step" },
      //{ "Two-Step Efficient GMM"                   , CTL_CHECK, i_twostep  , "two-step" },
      //{ "Iterated GMM"                             , CTL_CHECK, i_iterated , "iterated" },
      //{ "Continously Updated GMM"                  , CTL_CHECK, i_cu       , "cu" },
        { "Weight Matrix Estimation:"                , CTL_GROUP, 1 },
      //{ "Estimator"                                , CTL_LABEL },
        { "IID Moments"                              , CTL_RADIO, wmethod    ,"moments" },
        { "Heteroskedastic Moments (HC)"             , CTL_RADIO },
        { "Het. and Autocorrelated Moments (HAC)"    , CTL_RADIO },
{ "", CTL_ENABLER, 2, 1 },        
        { "HAC Kernel Settings:"                     , CTL_GROUP, 0 },
        { "Kernel:"                                  , CTL_LABEL },
        { "Bartlett"                                 , CTL_RADIO, kernel     ,"kernel" },
        { "Quadratic Spectral"                       , CTL_RADIO },
        { "Parzen"                                   , CTL_RADIO },
        { "Truncated"                                , CTL_RADIO },
        { "Bandwidth Choice:"                        , CTL_LABEL },
        { "Automatic"                                , CTL_CHECK, isauto     , "autobw" },
{ "", CTL_DISABLER, 1, 1 },        
        { "Manual Bandwidth"                         , CTL_DOUBLE,manualband , "double" },
        { "Print/graph Kernel Weight"                , CTL_CHECK, kernelprint, "kw" },
        { "Other Settings:"                          , CTL_GROUP, 1 },
        { "Maximum Number of Iterations"             , CTL_DOUBLE, maxit       , "sdouble" },
        { "Specify initial / One-Step weight matrix" , CTL_CHECK , SetInitialW , "sdouble" },
        { "Print final weight matrix"                , CTL_CHECK , PrintFinalW , "sdouble" },
        { "Linear model:"                            , CTL_GROUP, 1 },
        { "The model is linear (choose l.h.s. variable first)"    , CTL_CHECK, islinear    , "sdouble2" },
        { "Subset test:"                             , CTL_GROUP, 1 },
        { "Test for subset of moment conditions"     , CTL_CHECK , issubset , "sdouble" },
        { "Check all combinations up to 2"           , CTL_CHECK , allsubset , "sdouble" },
{ "", CTL_ENABLER, 0, 1 },        
        { "Specify moment numbers e.g. 0,2"          , CTL_STRMAT, subset , "sdouble" }
    };

  if (!"OxPackDialog"("Model Settings", adlg, &asoptions, &avalues))
  return FALSE;

  //println("\n*** OxPackDialog\n", "asoptions=", asoptions, "avalues=", avalues);

  i_method    = avalues[0];
  wmethod     = avalues[1];
  kernel      = avalues[2];
  if(avalues[3]==1) manualband=0;
  else              manualband=avalues[4];
  kernelprint = avalues[5];
  maxit       = avalues[6];
  SetInitialW = avalues[7];
  PrintFinalW = avalues[8];
  islinear    = avalues[9];
  issubset    = avalues[10];
  allsubset   = avalues[11];
  subset      = avalues[12];
  if(issubset==1 && subset==<>) allsubset=1;

  if(i_method==0) i_onestep =1; else i_onestep =0;
  if(i_method==1) i_twostep =1; else i_twostep =0;
  if(i_method==2) i_iterated=1; else i_iterated=0;
  if(i_method==3) i_cu      =1; else i_cu      =0;
  
  //println(i_onestep," ",i_twostep," ",i_iterated," ",i_cu);
  return TRUE;
  }
  
GMM::SendSpecials()
  {
  return {"Constant","Trend","Seasonal"};
  }   

GMM::SendVarStatus()
  {
  //  if (m_iModelClass == MC_GMM)
  return {{ "&Model Variable"       ,'M' ,STATUS_GROUP +STATUS_SPECIAL+STATUS_DEFAULT , Y_VAR},
          { "&Instrument"           ,'I' ,STATUS_GROUP2+STATUS_SPECIAL                , I_VAR} };
  }

GMM::ReceiveModel()
  {
  // get data: Y,I

  // get selection of database variables
  Select(Y_VAR, "OxPackGetData"("SelGroup", Y_VAR));
  Select(I_VAR, "OxPackGetData"("SelGroup", I_VAR));


  //if(samp_set==0) SetSelSample(-1, 0, -1, 0);
  //else            SetSelSampleByIndex(samp_start,samp_end);


  //s_sample = GetSelSample();
  //
  ////Modelbase::ReceiveModel();    
  //
  //m_mY = GetGroup(Y_VAR);
  //m_mX = GetGroup(I_VAR);
  //
  //GetGroupNames(Y_VAR, &m_asY);
  //GetGroupNames(I_VAR, &m_asX);

  //HBN: Select clears the selection sample; default to full
  SetSelSample(-1, 0, -1, 0);  
  }

GMM::InitPar()
  {
  Modelbase::InitPar();   // first call Modelbase version
  return TRUE;
  }
  
GMM::InitData()
  {
  s_sample = GetSelSample();

  //remember selection to next call
  m_iT1est = m_iT1sel;
  m_iT2est = m_iT2sel;

  //some text
  samp_start = GetSelStart();
  samp_end   = GetSelEnd();
  
  //Modelbase::ReceiveModel();    

  m_mY = GetGroup(Y_VAR);
  m_mX = GetGroup(I_VAR);

  GetGroupNames(Y_VAR, &m_asY);
  GetGroupNames(I_VAR, &m_asX);
  
  return TRUE;
  }


GMM::fprintmat( filen , mmat , ddec)
  {
  decl i,j,form;
  form = sprint("%",8+ddec,".",ddec,"f");
  //println("Matrix for later use:");
  fprint(filen,"\n = <");
  for(i=0;i<=rows(mmat)-1;++i)
    {
    for(j=0;j<=columns(mmat)-1;++j)
      {
      if(j<columns(mmat)-1)
        {
        fprint(filen,form,mmat[i][j],",");
        }
      else if (j==columns(mmat)-1 && i==rows(mmat)-1)
        {
        fprint(filen,form,mmat[i][j],">;\n");
        }
      else
        {
        fprint(filen,form,mmat[i][j],";\n    ");
        }
      }
    }
  }
  
GMM::DoEstimation(vP)
  {
  decl i,j,p,k,r;

  p = columns(m_mY);
  r = columns(m_mX);

  //get data
  Y = new array[p];
  Z = new array[r];
  a = zeros(20,1);

  //Model variables
  for(i=0;i<=p-1;++i)
    {
    Y[i]   = m_mY[][i];
    }

  //instruments
  for(i=0;i<=r-1;++i)
    {
    Z[i]   = m_mX[][i];
    }

  //generate help text
  s_help   = sprint("The model contains the following variables:\n");
  decl dz=0;
  s_help = s_help+sprint("\n         Model     Instr.");
  for(i=0;i<rows(Y);++i)
    {
    decl d=IsIn(m_asY[i],m_asX);
    if(d>=0)
      {
      s_help = s_help+sprint("\n         Y[","%2d",i,"]  =  Z[","%2d",dz,"]  =  ",m_asY[i]);
      dz=dz+1;
      }
    else
      {
      s_help = s_help+sprint("\n         Y[","%2d",i,"]            =  ",m_asY[i]);
      }
    }
  //  for(i=0;i<rows(Z);++i)
  //    {
  //    decl d=IsIn(m_asX[i],m_asY);
  //    if(d==-1)
  //      {
  //      s_help = s_help+sprint("\n                   Z[","%2d",dz,"]  =  ",m_asX[i]);
  //      dz=dz+1;
  //      }
  //    }
  decl tal = 0;
  s_help   = s_help+sprint("\n\n         Additional instruments:");
  s_help   = s_help+sprint("\n         Z[ ",dz,": ",rows(Z)-1,"]         =  ");
  for(i=0;i<rows(Z);++i)
    {
    decl d=IsIn(m_asX[i],m_asY);
    if(d==-1)
      {
      s_help = s_help+sprint( m_asX[i] , "  ");
      if(i<=rows(Z)-2) s_help = s_help+",  "; 
      else             s_help = s_help+";  "; 
      tal = tal + 1;
      if(tal==7)
        {
        tal=0;
        s_help = s_help+"\n                               ";
        }
      }
    }

  s_help   = s_help+sprint("\n\nParameter names are inclosed in {.}.");
  s_help = s_help+sprint("\n");   

  //parameters
  decl Pnames = {"Beta_0","Beta_1","Beta_2","Beta_3","Beta_4","Beta_5","Beta_6","Beta_7","Beta_8","Beta_9",
                 "Beta_10","Beta_11","Beta_12","Beta_13","Beta_14","Beta_15","Beta_16","Beta_17","Beta_18","Beta_19"};
  for(i=0;i<=20-1;++i)
    {
    a[i] = 0;
    //s_help = s_help+sprint("  a[",i,"] ");
    }

  //OLS
  s_inicode_l = "Uvec = Y[0]";
  for(i=1;i<=p-1;++i)
    {
    s_inicode_l = s_inicode_l+sprint(" - {"+Pnames[i]+"}*Y[",i,"]");
    }
  s_inicode_l = s_inicode_l+sprint(";\n");
  s_inicode_l = s_inicode_l+sprint("Gmat = Uvec .* ( Z[0]");
  for(i=1;i<=r-1;++i)
    {
    s_inicode_l = s_inicode_l+sprint(" ~ Z[",i,"]");
    }
  s_inicode_l = s_inicode_l+sprint(" );");
  //take last moment condition
  if(islinear==0)
    {
    if(n_model==1)
      {
      s_inicode = s_inicode_l;
      }
    else
      {
      s_inicode = s_code;
      }

    "OxPackSpecialDialog"("OP_TEXT",
                          "Specify Moment Conditions",
                          s_help,
                          s_inicode,
                          0,
                          "Example: The code for linear IV estimation is given by:\n"+s_inicode_l,
                          "*.txt",
                          "Text" ,
                          &s_code);
    }
  else
    {
    s_code = s_inicode_l;
    }

  //write code  
  decl filen = fopen(oxfilename(1)+"\\rungmm.ox", "w");

  fprintln(filen,"#include <"+oxfilename(1)+"\\gmmproc.ox>");

  decl code,names;
  [code,names] = TranslateToOxCode(s_code);
  fprintln(filen,"\nmom(const a)");
  fprint(filen,"  {");
  fprintln(filen, code);
  fprintln(filen,"\n  return Gmat;");
  fprintln(filen,"  }");

  fprintln(filen,"\nmain()");
  fprintln(filen,"  {");

  fprint(filen,"\n  s_model = \"",s_sample,"\";");
  fprint(filen,"\n  n_model = ",n_model,";");

  fprint(filen,"\n  names_y = new array[",rows(Y),"];  ");
  for(i=0;i<=rows(Y)-1;++i)
    {
    fprint(filen,"\n  names_y[",i,"] = \"",m_asY[i],"\";");
    }
  fprint(filen,"\n  names_z = new array[",rows(Z),"];  ");
  for(i=0;i<=rows(Z)-1;++i)
    {
    fprint(filen,"\n  names_z[",i,"] = \"",m_asX[i],"\";");
    }
  
  fprint(filen,"\n  m_model = new array[",20,"];  ");
  decl h1,h2,Names;
  h2 = s_code+" ";
  
  for(i=0;i<=50;++i)
    {
    if(strfind(strtrim(h2),"\n")==0)
      {
      h2 = h2[2:];
      }
    if(strfind(h2,"\n")>=1)
      {
      h1 = h2[0:strfind(h2,"\n")-1];
      h2 = h2[strfind(h2,"\n")+1:];
      fprint(filen,"\n  m_model[",i,"] = \""+strtrim(h1)+"\";");
      }
    else
      {
      break;
      }
    }
  fprint(filen,"\n  m_model[",i,"] = \""+strtrim(h2)+"\";\n");

  fprint(filen,"  Y = new array[",rows(Y),"];  ");
  for(i=0;i<=rows(Y)-1;++i)
    {
    fprint(filen,"\n  Y[",i,"] = <\n");
    for(j=0;j<=rows(Y[i])-1;++j)
      {
      fprint(filen,"          ","%#20.18f",Y[i][j]);
      if(j<rows(Y[i])-1) fprint(filen,";\n");
      }
    fprint(filen,">;");      
    }
  fprint(filen,"\n  Z = new array[",rows(Z),"];  ");
  for(i=0;i<=rows(Z)-1;++i)
    {
    fprint(filen,"\n  Z[",i,"] = <\n");
    for(j=0;j<=rows(Z[i])-1;++j)
      {
      fprint(filen,"          ","%#20.18f",Z[i][j]);
      if(j<rows(Z[i])-1) fprint(filen,";\n");
      }
    fprint(filen,">;");      
    }

  fprint(filen,"\n  names_P = new array[",rows(names),"];  ");
  for(i=0;i<=rows(names)-1;++i)
    {
    fprint(filen,"\n  names_P[",i,"] = \"",names[i],"\";");
    }

  if(SetInitialW==1)
    {
    decl iniW;                      
    "OxPackSpecialDialog"("OP_MATRIX",
                          "Initial / One-Step Weigth Matrix",
                          "Specify the initial or One-Step weigth matrix",
                          unit(rows(Z)),
                          1, 20 , 1 , 20,
                          0,
                          0,0,
                          " ",
                          &iniW);
    fprintln(filen,"\niniW");
    fprintmat(filen,iniW,18);
    }
    
  fprintln(filen,"\n\n  gmmfunc(",wmethod,",",kernel,",",manualband,",",1,",",i_onestep,",",i_twostep,",",i_iterated,",",i_cu,",",maxit,",",kernelprint,",",PrintFinalW,");");

  if(issubset==1)
    {
    if(allsubset==1)
      {
      fprint(filen,sprint("\n  CMtest(<-1>);"));
      }
    else
      {
      fprint(filen,sprint("\n  CMtest(<",subset[0]));
      for(decl i=1;i<rows(vec(subset));++i)
        {
        fprint(filen,sprint(",",subset[i]));
        }
      fprintln(filen,">);");
      }
    }
    
  fprintln(filen,"\n  }");
  fclose(filen);


  /*
  //old implementastion using systemcall()
  
  //construct bat script
  decl Bfilen = fopen(oxpath0+"\\startgmm.bat", "w");
  fprintln(Bfilen,"@echo off");
  fprintln(Bfilen,"start \""+"\" "+"\""+oxpath+"/oxrun.exe\"  \""+oxpath0+"/rungmm\"");
  fprintln(Bfilen,"exit");
  fclose(Bfilen);

  //  decl call = sprint("\""+oxpath+"/oxrun.exe\"  "+oxpath0+"/rungmm");

  //run bat script
  decl call = sprint("\""+oxpath0+"/startgmm.bat"+"\" ");
  systemcall(call);  

  //systemcall(sprint("\"c:/program files/oxmetrics4/bin/oxmetrics.exe c:/program files/oxmetrics4/ox/packages/gmm/rungmm.out\""));
    //systemcall("c:\\program files\\oxmetrics4\\bin\\oxmetrics.exe c:\\program files\\oxmetrics4\\ox\\packages\\gmm\\rungmm.out");
    //systemcall("\"c:\\program~1\\oxmetrics4\\ox\\packages\\gmm\\rungmm.ox\"");
    //systemcall("c:\\program~1\\oxmetrics4\\ox\\bin\\oxli.exe c:\\program~1\\oxmetrics4\\ox\\packages\\gmm\\rungmm.ox");
    //systemcall("c:\\program files\\oxmetrics4\\bin\\oxmetrics.exe c:\\program files\\oxmetrics4\\ox\\packages\\gmm\\rungmm.out");
    //return {vP, "BFGS", FALSE};       // three return values
  */

  //run code
  //"OxPackOxRun"(oxfilename(1)+"/rungmm\"");
  "OxPackOxRun"(oxfilename(1)+"rungmm");
  n_model = n_model+1;
  }

  
GMM::Covar()
  {
  //decl mhess;
  //if (Num2Derivative(fProbit, m_vPar, &mhess))
  //{
  //    m_mCovar = -invert(mhess) / m_cT;
  //}
  }   

  
GMM::Output()
  {
  //Buffering(11);
  // set text marker and start buffering
  // Now, this Output can only be used from OxPack. Normally
  // there would be a base class with all the computational class,
  // and a derived class that only has the OxPack specific code.

  // print the header even if estimation failed
  //OutputHeader(GetMethodLabel());

  //if (m_iModelStatus == MS_ESTIMATED)
  //{
      // output the rest
  //  OutputPar();
  //    OutputLogLik();
  //}
  //Buffering(0);     // stop buffering
  }


///////////////////////////////////////////////////////////////////////
// OxPack specific
GMM::Buffering(const iBufferOn)
  {
  if(iBufferOn == 11)
    {
    "OxPackSetMarker"(TRUE);
    "OxPackBufferOn"();
     }
  else if (iBufferOn == 1)
    "OxPackBufferOn"();
  else
    "OxPackBufferOff"();
  }

//GMM::IsCrossSection()
//{
//  return TRUE;
//}
//GMM::GetModelLabel()
//{
//  return sprint("CS(", "%2d", m_iModel, ")");
//}
//GMM::GetMethodLabel()
//{
//  decl asmethods = {"Logit", "Probit", "Poisson", "NegBin"};
//  return asmethods[m_iMethod];
//}

//GMM::DoOption(const sOpt, const val)
//{
//    if (sOpt == "covunw")
//        m_fCovarUnweighted = val;
//}
//GMM::DoGraphicsDlg()
//{
//    decl adlg, asoptions, avalues;
//    
//    adlg =
//    {   { "Graphic Analysis" },
//        { "Histograms of probabilities for each state",
//                CTL_CHECK, 1, "hist" },
//        { "Histograms of probabilities of observed state",
//                CTL_CHECK, 1, "histobs" },
//        { "Number of bars:", CTL_INT, 10, "bars" },
//        { "Cumulative correct predictions for each state",
//                CTL_CHECK, 0, "ccp" },
//        { "Unsorted", CTL_RADIO, 1, "sort" },
//        { "Sorted by probability", CTL_RADIO },
//        { "Sorted by log-likelihood contribution", CTL_RADIO },
//        { "Cumulative response for each state",
//                CTL_CHECK, 0, "crf" }
//    };
//
//    if (!"OxPackDialog"("Graphic Analysis", adlg, &asoptions, &avalues))
//        return FALSE;
//
//    // process user actions for graphics dialog
//
//    decl iplot = 0;
//    
//    // call functions if requested
//    if (iplot)
//        ShowDrawWindow();
//    return TRUE;
//}


GMM::LoadOptions()
  {
  // load persistent settings
  Modelbase::LoadOptions();
    
  m_iModelClass = "OxPackReadProfileInt"(0,"class", 0);
  //m_fCovarUnweighted = "OxPackReadProfileInt"(0,"covunw", 0);
  }
GMM::SaveOptions()
  {
  // save persistent settings
  "OxPackWriteProfileInt"(0,"class", m_iModelClass);
  //"OxPackWriteProfileInt"(0,"covunw", m_fCovarUnweighted);

  Modelbase::SaveOptions();
  }
GMM::GetModelSettings()
  {
  decl aval = Modelbase::GetModelSettings();

  // add any model settings that must be remembered for recall
  // could be something like:
  //      aval ~=
  //      {   {   m_iModelType,       "m_iModelType"      }
  //      };

  return aval;
  }
GMM::SetModelSettings(const aValues)
  {
  // allows for model settings storage in model history
  if (!isarray(aValues))
    return;

  // first let Modelbase have a look
  Modelbase::SetModelSettings(aValues);

  // then handle GMM specific settings
  for (decl i = 0; i < sizeof(aValues); ++i)
    {
    //      if (aValues[i][1] == "m_iModelType")
    //          m_iModelType = aValues[i][0];
    }
  }