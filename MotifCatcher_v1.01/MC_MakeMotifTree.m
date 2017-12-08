function [Tree DirectoryList] = MC_MakeMotifTree(DataSetProfile)
%Description: this function creates a motif tree from the motifs associated
%with a set of related subsets.

%Retrieve R, and write out a list of directories.
DirectoryList = MC_GetR(DataSetProfile.Directories.RMEME);

%output file for significant PWMs.
outputfile = strcat(DataSetProfile.Directories.MotifTree,'/SignificantR_PWMs');

%update directory list - cutoff for tree building.
[EmptyFlag DirectoryList] = MC_GetTransfacPWMs(DirectoryList,outputfile,DataSetProfile.Directories,DataSetProfile.MotifTree_parameters);

if EmptyFlag == false

%(2) Export TransFac matrices to STAMP, Build tree.
% ----------------------------------------------------------------------- %

%explanations of cmd:
%-tf = TransFac format, input motifs
%-sd = score distribution file
%-cc = Pearson Correlation Coefficient (PCC)
%-align SWU = Smith-Waterman ungapped (SWU)
%-match = needs to be there for the STAMP program to run properly

cmd = [DataSetProfile.ProgramLocations.STAMP ' -tf ' outputfile ' -sd ' DataSetProfile.ProgramLocations.STAMPScores ' -cc ' DataSetProfile.MotifTree_parameters.ColComparison '  -align ' DataSetProfile.MotifTree_parameters.AlignmentScheme ' -out ' outputfile ' -match ' DataSetProfile.ProgramLocations.STAMPDatabase];

system(cmd)

%(3) Cladogram tree of ES, and Motif Families
% ----------------------------------------------------------------------- %

%import output tree into matlab
Tree = phytreeread(strcat(outputfile,'.tree'));
else
   Tree = [];
   disp('No significant related subset motifs to build a tree out of.');
end
end