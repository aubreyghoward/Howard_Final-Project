function LastIterations = MC_GetR(RDirectory)
%Description: This function determines the appropriate related subsets 
%for future analysis
%
%Inputs:
%   RDirectory: 
%       Directory containing all related subsets
%  
%Outputs:
%   LastIterations:
%       MEME output dirctories of last iterations (related subsets)
%   FileList:
%       list of files/directories in EndState folder, directly after
%       End State generation step.

%create a list of files in the end state directory.
FileList = strcat(RDirectory,'/files.txt');
cmd = ['ls ' RDirectory ' > ' FileList];
system(cmd);

%import list of files with directory contents.
fid = fopen(FileList,'r');
filecontents = textscan(fid,'%s');
fclose(fid);

%determine total number of clusters to extract
numcluster = 0;
for i = 1:length(filecontents{1,1})
   if strfind(filecontents{1,1}{i,1},'Seed')
       A = strtok(filecontents{1,1}{i,1},'v');
       
       value = sscanf(A,'Seed%d');
       
       if value >= numcluster
           numcluster = value;
       end
   end
end

%initialize LastIterations output
LastIterations = cell(1,numcluster);

%for each cluster, find the top iteration.
for i = 1:numcluster
    
    lookfor = strcat('Seed',num2str(i),'v');
    LastIteration = 0;
    
    %find top iteration
    for j = 1:length(filecontents{1,1})
       if strfind(filecontents{1,1}{j,1},lookfor)
           [~, A] = strtok(filecontents{1,1}{j,1},'v');
           
           value = str2double(A(2:length(A)));
           
           if value >= LastIteration
              LastIteration = value; 
           end
      
       end 
    end
    
    %write final iteration information
    LastIterations{1,i} = strcat('Seed',num2str(i),'v',num2str(LastIteration));
    
end

end