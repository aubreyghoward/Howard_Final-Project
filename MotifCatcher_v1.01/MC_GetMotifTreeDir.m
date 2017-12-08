function MotifTreeFile = MC_GetMotifTreeDir
% Description: gather inputs for retrieving motif tree information, for
% clustering/family etc
%
% Input:    none  
%                   
% Output:   Directories              = list of directories to create
%           MEME_parameters          = Parameters to send to MEME
%           ES_parameters            = Parameters related to
%                                         ES-generation
%           Clustering_parameters    = Clustering Parameters
%          

%% Define Input, Name Output

%Define Root Directory, and location of Dataset Sequences File
prompt1={'Motif Tree / Stamp Output directory (whole path)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name1='Give the location of the desired motif tree file.';
numlines=1;
defaultanswer1={''};
answer1=(inputdlg(prompt1,name1,numlines,defaultanswer1,options));

%gather user responses.
MotifTreeFile = answer1{1,1};

%after all inputs gathered, close the current figure window.
close(gcf);

