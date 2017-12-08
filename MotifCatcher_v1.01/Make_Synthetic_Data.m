%Description: This script creates a synthetic data file for use in testing
%he MotifCatcher framework.
%
% Change key variables in the 'Changeable variables' section
% Create synthetic data according to your variables in the 'create data'
% section
%
% Note that changing the variables will require changing some details about
% the MotifCatcher search example provided in the README file.

%%
% ----------------------------------------------------------------------- %
% Changeable Variables -------------------------------------------------- %
% ----------------------------------------------------------------------- %

%define number of nucleotides / sequences
%change these parameters to create alternative synthetic data sets.
NumofNucs = 400;
NumofSeqs = 40;

%randomize motif-containing sequence islands
X = randperm(NumofSeqs);

%segment into groups
Both = [];
Neither = X(1:10);
Motif1 = X(11:25);
Motif2 = X(26:40);

%define motifs
m1 = 'ATATATATATATATAT';
m2 = 'CGCGCGCGCGCGCGCG';

%%
% ----------------------------------------------------------------------- %
% Create data ----------------------------------------------------------- %
% ----------------------------------------------------------------------- %

%open file
fid = fopen('Synthetic_Data.fasta','w');

for j = 1:NumofSeqs
    
    
    %title sequence entry
    entry = strcat('>[Sequence_Entry_',num2str(j),']');
    
    %create background sequence
    Y = randperm(NumofNucs);
    seqs = char(zeros(1,400));
    
    for i = 1:NumofNucs;
       x = randi([1 4],1);
       if mod(Y(i),4) == 0
           seqs(i) = 'T';
       elseif mod(Y(i),4) == 1
           seqs(i) = 'A';
       elseif mod(Y(i),4) == 2
           seqs(i) = 'C';
       else
           seqs(i) = 'G';
       end
    end

    if ~isempty(intersect(Both,j))
        
    %insert motif(s), if appropriate
    KeepChecking = true;
    InsertMotifPoint = 1;
        
     %find apropriate insert point
     while(KeepChecking == true)
        a = find(Y==InsertMotifPoint); 
         if a + length(m1) < NumofNucs
             KeepChecking = false;
         end
         InsertMotifPoint = InsertMotifPoint + 1;
     end
     
     %insert sequence
     seqs(a:a+length(m1)-1) = m1;
              
     %without overlapping with the first inserted motif, insert the second
     %motif.
     
     %find appropriate insert point
     KeepChecking = true;
     while(KeepChecking == true)
        b = find(Y==InsertMotifPoint); 
         if b + length(m2) < NumofNucs && abs(a-b) > max(length(m1),length(m2))
             KeepChecking = false;
         end
         InsertMotifPoint = InsertMotifPoint + 1;
     end
     
     %insert sequence
     seqs(b:b+length(m2)-1) = m2;
     
    elseif ~isempty(intersect(Motif1,j))

    %insert motif(s), if appropriate
    KeepChecking = true;
    InsertMotifPoint = 1;
    
     %find apropriate insert point  
     while(KeepChecking == true)
        a = find(Y==InsertMotifPoint); 
         if a + length(m1) < NumofNucs
             KeepChecking = false;
         end
         InsertMotifPoint = InsertMotifPoint + 1;
     end
     
     %insert sequence
     seqs(a:a+length(m1)-1) = m1;
     
    elseif ~isempty(intersect(Motif2,j))

    %insert motif(s), if appropriate
    KeepChecking = true;
    InsertMotifPoint = 1;
    
     %find aprpropriate insert point
     while(KeepChecking == true)
        b = find(Y==InsertMotifPoint); 
         if b + length(m2) < NumofNucs
             KeepChecking = false;
         end
         InsertMotifPoint = InsertMotifPoint + 1;
     end
     
     %insert sequence
     seqs(b:b+length(m2)-1) = m2;
     
    end
        %write info to file
        fprintf(fid,'%s\n',entry);
        fprintf(fid,'%s\n\n',seqs);
end
fclose(fid);