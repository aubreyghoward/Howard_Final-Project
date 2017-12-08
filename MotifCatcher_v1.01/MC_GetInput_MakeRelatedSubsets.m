function [SeqFile Directories MEME_parameters R_parameters ProgramLocations] = MC_GetInput_MakeRelatedSubsets
% Description: function that gathers all input parameters required to make
% a related set of subsets
% 
%
%
% 
% Input:    none  
%                   
% Output:   SeqFile                  = Input sequences data set
%           Directories              = list of directories to create
%           MEME_parameters          = Parameters to send to MEME
%           R_parameters             = Parameters related to
%                                         R-generation
%           ProgramLocations         = Location (on system) of dependent
%                                         programs

%% Define Input, Name Output

%Define Root Directory, and location of Dataset Sequences File
prompt1={'Define Root Directory (whole path)',...
    'Dataset Sequences File (.fasta format)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name1='Select input dataset file, and define a preferred root output directory.';
numlines=1;
defaultanswer1={'',''};
answer1=(inputdlg(prompt1,name1,numlines,defaultanswer1,options));

%gather user responses.
Directories = struct();
Directories.root = answer1{1,1};
SeqFile = answer1{2,1};

%Name subdirectories within output directory.
prompt2={'Related subset directory (Sequences)',...
    'Related subset directory (MEME output)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name2='Define output sub-directories';
numlines=1;
defaultanswer2={strcat(Directories.root,'/RSeqs'),...
    strcat(Directories.root,'/RMEME'),...
    };

answer2=(inputdlg(prompt2,name2,numlines,defaultanswer2,options));

%gather user responses.
Directories.RSeqs = answer2{1,1};
Directories.RMEME = answer2{2,1};

%import fasta file, to determine defaults, and check if .fasta file is real
Seq = fastaread(SeqFile);

%% Gather MEME and MAST parameters

prompt3={'Minimum Motif Width (in nt)','Maximum Motif Width (in nt)', ...
    'Which Alphabet? (d for dna, p for protein)',...
    'Check for motifs on reverse strand (REVERSE COMPLEMENT)? (y/n)',...
    'Force palindromes? (y/n) (selecting yes requires dna alphabet',...
    'Maximal MAST E-value for use in iterative search?',...
    'Alternative background file (from input-sequences-derived background)'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name3='Define All relevant MEME Parameters';
numlines=1;
defaultanswer3={'6','24','d','y','n','10',''};
answer3=(inputdlg(prompt3,name3,numlines,defaultanswer3,options));

%gather user responses.
MEME_parameters.MinWidth = str2double(answer3{1,1});
MEME_parameters.MaxWidth = str2double(answer3{2,1});

if strmatch(answer3{3,1},'p') 
    MEME_parameters.Alphabet = 'protein';
elseif strmatch(answer3{3,1},'protein')
    MEME_parameters.Alphabet = 'protein';
else
    MEME_parameters.Alphabet = 'dna';
end

if strmatch(answer3{4,1},'y') 
    MEME_parameters.RevComp = true;
elseif strmatch(answer3{4,1},'yes')
    MEME_parameters.RevComp = true;
else
    MEME_parameters.RevComp = false;
end

if strmatch(answer3{5,1},'y') 
    MEME_parameters.ForcePal = true;
    MEME_parameters.Alphabet = 'dna';
elseif strmatch(answer3{5,1},'yes')
    MEME_parameters.ForcePal = true;
    MEME_parameters.Alphabet = 'dna';
else
    MEME_parameters.ForcePal = false;
end

MEME_parameters.MastThreshold = str2double(answer3{6,1});

%alternative bfile
MEME_parameters.bfile = answer3{7,1};

%% Gather R Parameters

%default parameters here are computed based on size of input dataset
defaultseeds = num2str(length(Seq)*10); %10*whole dataset
defaultseedsize = num2str(round(length(Seq)*.1)); %10% of whole dataset

prompt4={'How many random seeds would you like to create?',...
    'How large should each random seed be?'};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name4='Define parameters relevant to generating individual related subsets';
numlines=1;
defaultanswer4={defaultseeds,defaultseedsize};
answer4=(inputdlg(prompt4,name4,numlines,defaultanswer4,options));

SearchStyle = MC_inputSearchStyle;

%gather user responses.
R_parameters.Seeds = str2double(answer4{1,1});
R_parameters.SeedSize = str2double(answer4{2,1});
R_parameters.SearchStyle = SearchStyle;


%% Determine Locations of Dependent Programs

prompt6={'MEME full path executable',...
    'Full path location of included MEME program ''fasta-get-markov''',...
    'Full path location of included MEME program ''MAST'''};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

name6='the MEME and STAMP programs need to be installed and operational to work correctly.  Please enter the locations of the following components on your system.';
numlines=1;
defaultanswer6={'',...
    '',...
    ''};

answer6=(inputdlg(prompt6,name6,numlines,defaultanswer6,options));

%gather user responses.
ProgramLocations.MEME          = answer6{1,1};
ProgramLocations.FastaGetMarkov= answer6{2,1};
ProgramLocations.MAST          = answer6{3,1};

%%

%after all inputs gathered, close the current figure window.
close(gcf);

