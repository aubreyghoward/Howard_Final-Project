function [Families AllMotifsAndLocations] = MC_MakeClusters(DataSetProfile,ClusteringThreshold)
   
% (1) Compute clusters and retrieve Motif Tree
% ----------------------------------------------------------------------- %

    [LeafClusters,~] = ...
        cluster(DataSetProfile.Tree,...
        ClusteringThreshold);
    
    %retrieve information from tree
    PhyTreeInfo = get(DataSetProfile.Tree);
    
% (2) Create 'Families' output.
% ----------------------------------------------------------------------- %

    %initialize 'Families' structure
    Families = cell(max(LeafClusters),1);

    %transfer information from Motif Tree output to AllCoreMotifs form,
    %and note family grouping.
    for j = 1:max(LeafClusters)
        for i = 1:length(PhyTreeInfo.LeafNames)

           if LeafClusters(i,1) == j

               %find 'AllCoreMotifs' number, from the 'Leaf Nodes' name
               %argument.

              for k = 1:length(DataSetProfile.DirectoryList) 
                if strfind(DataSetProfile.DirectoryList{1,k},PhyTreeInfo.LeafNames{i,1})
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
    
% (3) Create 'AllMotifsAndLocations' output.
% ----------------------------------------------------------------------- %

%import fasta file.
[SeqFileHeader Sequence] = fastaread(DataSetProfile.SeqFile);

AllMotifsAndLocations = cell(1,length(Families));
% Each cell entry: a Final Cluster Family.  Within each cell entry, each
% row is a particular ES, and each column a particular site.  In other
% words - each cell is a mini 'Membership Matrix' for each family.
for i = 1:length(Families)
    InputSet = []; 
    ICounter = 0;
    Header = [];
    
    for j = 1:length(Families{i,1}) 
        ICounter = ICounter + 1;
        InputSet{1,ICounter} = strcat(DataSetProfile.Directories.RMEME,'/',char(DataSetProfile.DirectoryList(1,Families{i,1}(j))));
        
        %build header for future output structure.
        Header{1,ICounter+1} = Families{i,1}(j);
        Header{2,ICounter+1} = char(DataSetProfile.DirectoryList(1,Families{i,1}(j)));
    end

%retrieve each familial membership matrix.
MM = MC_MakeMembershipMatrix(InputSet,SeqFileHeader,DataSetProfile.MEME_parameters.RevComp);

%combine header and MM for output.
AllMotifsAndLocations{1,i} = vertcat(Header,MM);
end

end