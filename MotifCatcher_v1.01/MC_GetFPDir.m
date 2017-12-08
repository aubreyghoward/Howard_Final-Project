function FPdir = MC_GetFPDir
%Description: input-gathering function for FP directory.

%Define Root Directory, and location of Dataset Sequences File
prompt1={'FP Directory (whole path)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name1='Give the location of the desired set of FP output folders.';
numlines=1;
defaultanswer1={''};
answer1=(inputdlg(prompt1,name1,numlines,defaultanswer1,options));

%gather user responses.
FPdir = answer1{1,1};

%after all inputs gathered, close the current figure window.
close(gcf);




end