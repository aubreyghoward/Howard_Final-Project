function MotifMap = MC_MakeMotifMap(Directories,SeqFile,RevComp)
%After clusters, families, etc have been determined on a given dataset,
%this command generates the final, overall MotifMap.  a MotifMap is an
%object that describes significant motifs in the entire dataset.
%
%Inputs:
%   Directory
%       Folder containing all information from previous analyses, but most
%       importantly, meme output directories with FBP stuff.
%       FBP (R,x) taken from each Family output file.
%   SeqFile
%       .fasta file containing all sequences in the superset.
%   RevComp
%       motifs may be found on (+) or (-) strand, or just (+) strand
%
%Outputs:
%   MotifMap
%       Output structure in the same form of 'AllMotifsAndLocations',
%       except instead of runs, labeled by Family.
%       As per design in the 'directory' folder, Families are automatically
%       numbered by their rank of convergence (Family 1 describes related
%       ES most often converged, Family 2 second-most-often, etc).
%           row 1: Family, with Family Number
%           row 2: regular expression
%           row 3-end: sites (col 1), localization (other columns)

%Import sequences information
[SeqFileHeader ~] = fastaread(SeqFile);

%build a list of all MEME output directories.
list = strcat(Directories.FP,'/files.txt');
system(['ls -a ' Directories.FP ' > ' list]);

%re-import
fid = fopen(list);
extraction = textscan(fid,'%s');
fclose(fid);

%find the total number of families.
MaxFam = 0;
for j = 1:length(extraction{1,1})
   if strfind(extraction{1,1}{j,1},'Family')
       num = strtok(extraction{1,1}{j,1},'Family');
       if ~isempty(num)
           maxN = str2double(num);
           if maxN > MaxFam
              MaxFam = maxN; 
           end
       end
   end
end

if MaxFam ~= 0

%build Headers
Headers = cell(3,MaxFam);

%build InputSet
%initialize
InputSet = cell(1,MaxFam);
for i = 1:MaxFam
    InputSet{1,i} = strcat(Directories.FP,'/Family',num2str(i));
    Headers{1,i} = strcat('Family',num2str(i));
end

%headers are families and consensus sequence.
for i = 1:MaxFam
    file = strcat(InputSet{1,i},'/meme.txt');
    Headers{2,i} = MC_GetRegularExpression(file);
    Headers{3,i} = MC_GetMotif(file);
end

%retrieve MotifMap
[MotifMap ~] = MC_MakeMembershipMatrixwHeader(InputSet,SeqFileHeader,Headers,RevComp);

% Finally, sequences that did not involve any motifs are appended to the
% end of the structure.
Counter = length(MotifMap(:,1));

for i = 1:length(SeqFileHeader)
   %default: add all sequences
   DoNotAdd = false;
   
   %if the sequence is already written in the structure, however, no need
   %to add it.
   for j = length(Headers(:,1))+1:Counter
      if ~isempty(strmatch(MotifMap{j,1},SeqFileHeader{1,i}))
          DoNotAdd = true;
      end
   end
   
   %write to structure.
   if DoNotAdd == false 
      Counter = Counter + 1;
      MotifMap{Counter,1} = SeqFileHeader{1,i};
   end
end

else
    error('No Motif Families were found in this directory');
end

end