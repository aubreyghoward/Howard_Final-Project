function [DirectoryList Tree Families AllMotifsAndLocations] = ...
    MC_ClusterR(MotifTree_parameters,Directories,MEME_parameters,...
    ProgramLocations,SeqFile,Clustering_parameters)
%Description:
%   If the whole pathway is utilized at once, this function creates a motif
%   tree, computes families, and familial profiles (FPs).

%(0) Import Sequence File
% ----------------------------------------------------------------------- %

%import fasta file.
[SeqFileHeader Sequence] = fastaread(SeqFile);

%(1) Retrieve Core Motifs from R, filter out high E-value motifs, merge to file
% ----------------------------------------------------------------------- %

%Retrieve R, and write out a list of directories.
DirectoryList = MC_GetR(Directories.RMEME);

%output file for significant PWMs.
outputfile = strcat(Directories.MotifTree,'/SignificantR_PWMs');

%updated version - cutoff for tree building.
EmptyFlag = MC_GetTransfacPWMs(DirectoryList,outputfile,Directories,MotifTree_parameters);

if EmptyFlag == false

%(2) Export TransFac matrices to STAMP, Build tree.
% ----------------------------------------------------------------------- %

%explanations of cmd:
%-tf = TransFac format, input motifs
%-sd = score distribution file
%-cc = Pearson Correlation Coefficient (PCC)
%-align SWU = Smith-Waterman ungapped (SWU)
%-match = needs to be there for the STAMP program to run properly

cmd = [ProgramLocations.STAMP ' -tf ' outputfile ' -sd ' ProgramLocations.STAMPScores ' -cc ' MotifTree_parameters.ColComparison '  -align ' MotifTree_parameters.AlignmentScheme ' -out ' outputfile ' -match ' ProgramLocations.STAMPDatabase];

%using STAMP-determined clusters 
if strmatch(Clustering_parameters.ManualCluster,'n')
    cmd = [cmd ' -chp'];
end

%end to command line
system(cmd)

%(3) Cladogram tree of R, and Motif Families
% ----------------------------------------------------------------------- %

%import output tree into matlab
Tree = phytreeread(strcat(outputfile,'.tree'));

%determine motif families, based on clustering similar leaves of the tree
%together, or using STAMP's auto-clustering approach
if strmatch(Clustering_parameters.ManualCluster,'n')

    %auto-clustering approach
    Families = MC_GetFamilies(strcat(outputfile,'_tree_clusters.txt'));
    
else %cluster manually

    %cluster according to user-specified threshold.
    [LeafClusters,NodeClusters] = ...
        cluster(Tree,Clustering_parameters.ClusteringThreshold);
    
    %retrieve information from tree
    PhyTreeInfo = get(Tree);

    %initialize 'Families' structure
    Families = cell(max(LeafClusters),1);

    %transfer information from phylogenic tree output to AllCoreMotifs form,
    %and note family grouping.
    for j = 1:max(LeafClusters)
        for i = 1:length(PhyTreeInfo.LeafNames)

           if LeafClusters(i,1) == j

               %find 'AllCoreMotifs' number, from the 'Leaf Nodes' name
               %argument.

              for k = 1:length(DirectoryList(1,:)) 
                if strfind(DirectoryList{1,k},PhyTreeInfo.LeafNames{i,1})
                   Num =  k;
                end
              end

              if isempty(Families(j,1))
                  Families{j,1} = Num;
              else
                  Families{j,1} = [Families{j,1} Num];
              end

           end
       end
    end
    
end

%Sort families by length (bubble sort).
for i = 1:length(Families)-1
   for j = 1:length(Families)-1
      if length(Families{j,1}) < length(Families{j+1})
          
          %store variable in temp
          temp = Families{j,1};
          
          %substitute
          Families{j,1} = Families{j+1,1};
          
          %re-write temp
          Families{j+1,1} = temp;
      end
   end
end

%(5) Create 'AllMotifsAndLocations' output.
% ----------------------------------------------------------------------- %

AllMotifsAndLocations = cell(1,length(Families));
% Each cell entry: a Final Cluster Family.  Within each cell entry, each
% row is a particular R, and each column a particular site.  In other
% words - each cell is a mini 'Membership Matrix' for each family.

for i = 1:length(Families)
    InputSet = []; 
    ICounter = 0;
    Header = [];
    
    for j = 1:length(Families{i,1}) 
        ICounter = ICounter + 1;
        InputSet{1,ICounter} = strcat(Directories.RMEME,'/',char(DirectoryList(1,Families{i,1}(j))));
        
        %build header for future output structure.
        Header{1,ICounter+1} = Families{i,1}(j);
        Header{2,ICounter+1} = char(DirectoryList(1,Families{i,1}(j)));
    end

%retrieve each familial membership matrix.
MM = MC_MakeMembershipMatrix(InputSet,SeqFileHeader,MEME_parameters.RevComp);

%combine header and MM for output.
AllMotifsAndLocations{1,i} = vertcat(Header,MM);
end

%(6) Generate Familial Binding Profile (FBP) - method 3
% ----------------------------------------------------------------------- %
% Extract sites from the 'Membership Motif' matrix for each run, and look
% for the best motif, given the same settings used to create that motif.

%disable append-to-file warning
warning('off','Bioinfo:fastawrite:AppendToFile'); 

%start off by making a directory to contain all the FBP sequence.
FPseq_dir = strcat(Directories.FP,'/Sequences');
system(['mkdir ' FPseq_dir]);

%obtain sites
Sites = MC_GetSharedSites(AllMotifsAndLocations,...
    Clustering_parameters.SharedSitesThreshold);

%create a .fasta file with key members from a given family.
for i = 1:length(Sites)
   
   %initialize a family file for each family
   familyfile = strcat(FPseq_dir,'/Family',num2str(i),'.fasta');
   
   %build each family file with the appropriate sequences
   for j = 1:length(Sites{1,i}) 
       for k = 1:length(SeqFileHeader)
            if ~isempty(strmatch(SeqFileHeader{1,k},Sites{1,i}{j,1}))
          fastawrite(familyfile,SeqFileHeader{1,k},Sequence{1,k}) 
            end
       end
   end
   
    %find the best motif possible for each familyfile.
    %make an output directory
    outputdir = strcat(Directories.FP,'/Family',num2str(i));
    cmd = ['mkdir ' outputdir];
    system(cmd);

    %input to meme program.
    %note that here we use 'oops' instead of 'zoops', this requires that
    %all input sites contain a motif.
    cmd = [ProgramLocations.MEME ' ' familyfile ' -minw ' num2str(MEME_parameters.MinWidth) ' -maxw ' num2str(MEME_parameters.MaxWidth) ' -' MEME_parameters.Alphabet ' -bfile ' MEME_parameters.bfile ' -mod oops -oc ' outputdir ' -nostatus -maxsize 1000000'];

    %option: search the reverse complement, or not.
    if MEME_parameters.RevComp == 1
       cmd = [cmd ' -revcomp']; 
    end
    
    %send to command line to create directories.
    system(cmd);
end

else
   disp(['There were no significant motifs found with an E-value of ' num2str(MotifTree_parameters.EValThreshold) ' or less.']);
   Tree  = [];
   Families  = [];
   AllMotifsAndLocations = [];
end

end