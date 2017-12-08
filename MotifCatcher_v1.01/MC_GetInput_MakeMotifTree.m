function [Directories MotifTree_parameters ProgramLocations] = MC_GetInput_MakeMotifTree(Source,Root)
% Description: gather input parameters required for converting a library of
% MEME-derived related subsets into a motif tree.
% 
% Input:    none  
%                   
% Output:   Directories              = list of directories to create
%           MotifTree_parameters     = Parameters to send to STAMP
%           ProgramLocations         = Location (on system) of dependent
%                                         programs

%% Define Input, Name Output
if Source == 0
%Define Root Directory, and location of Dataset Sequences File
prompt1={'Existing related subset motif directory (whole path)',... 
    'Define a motif tree output directory'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name1='Select related subset motif directory';
numlines=1;
defaultanswer1={'',''};
answer1=(inputdlg(prompt1,name1,numlines,defaultanswer1,options));

%gather user responses.
Directories = struct();
Directories.RMEME = answer1{1,1};
Directories.MotifTree = answer1{2,1};
end

if Source == 1
%Define Root Directory, and location of Dataset Sequences File
prompt1={'Define a Motif Tree output directory'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name1='Select related subset motif directory';
numlines=1;

MTdir = strcat(Root,'/MotifTree');
defaultanswer1={MTdir};
answer1=(inputdlg(prompt1,name1,numlines,defaultanswer1,options));

%gather user responses.
Directories = struct();
Directories.MotifTree = answer1{1,1};
    
end
%% Gather Motif Tree Parameters

prompt5={'What is the largest possible E-value (Expect Value) you allow?',...
    'What is the maximum number of significant related subset motifs to cluster?',...
    'Alignment scheme (enter one of the following: NW, SW, SWA, SWU)',...
    'What gap open penalty would you like to specify (if applicable)?',...
    'What gap extension penalty would you like to specify (if applicable)?',...
    'Column comparison metric (enter one of the following: PCC, ALLR, ALLRLL, CS, KL, SSD)',...
    };

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name5='Clustering and STAMP parameters.  For further explanation, see STAMP documentation.';
numlines=1;
defaultanswer5={'.001','100','SWA','1.00','0.50','ALLR'};
answer5=(inputdlg(prompt5,name5,numlines,defaultanswer5,options));

%gather user responses.
MotifTree_parameters.EValThreshold = str2double(answer5{1,1});
MotifTree_parameters.MaxR = str2double(answer5{2,1});
MotifTree_parameters.AlignmentScheme = answer5{3,1};
MotifTree_parameters.GapOpen = answer5{4,1};
MotifTree_parameters.GapExtension = answer5{5,1};
MotifTree_parameters.ColComparison = answer5{6,1};

%% Determine Locations of Dependent Programs

prompt6={...
    'STAMP full path executable',...
    'STAMP random score distributions source file',...
    'preferred STAMP database of established motifs to match with R motifs'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name6='the MEME and STAMP programs need to be installed and operational to work correctly.  Please enter the locations of the following components on your system.';
numlines=1;
defaultanswer6={...
    '',...
    '',...
    ''};

answer6=(inputdlg(prompt6,name6,numlines,defaultanswer6,options));

%gather user responses.
ProgramLocations.STAMP         = answer6{1,1};
ProgramLocations.STAMPScores   = answer6{2,1};
ProgramLocations.STAMPDatabase = answer6{3,1};

%%

%after all inputs gathered, close the current figure window.
close(gcf);
