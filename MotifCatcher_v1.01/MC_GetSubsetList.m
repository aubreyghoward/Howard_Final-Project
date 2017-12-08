function GeneList = MC_GetSubsetList(mastdirectory,header)
%Extract list of sequence entries from a mast .txt output file.  The format of the
%file depends on whether or not reverse-complement strands are allowed.

file = strcat(mastdirectory,'/mast.txt');

fid = fopen(file,'r');

%check for a valid file identifier
if fid ~= -1
    
extraction = textscan(fid,'%s');

%find location in the file where the matches list begins to be displayed.
for i = 1:length(extraction{1,1})-4
    if strcmp(char(extraction{1,1}{i,1}),'SEQUENCE') && ...
            strcmp(char(extraction{1,1}{i+1,1}),'NAME') && ...
            strcmp(char(extraction{1,1}{i+2,1}),'DESCRIPTION') && ...
            strcmp(char(extraction{1,1}{i+3,1}),'E-VALUE') && ...
            strcmp(char(extraction{1,1}{i+4,1}),'LENGTH')
            
            startindex = i+9;
            %display(startindex)
            break;
    end
end

%determine location in the file where GeneList are no longer displayed.
for i = startindex:length(extraction{1,1})
    if strcmp(char(extraction{1,1}{i,1}),...
            '********************************************************************************')

        stopindex = i-3;
        %display(stopindex)
        break
    end
end

%the GeneList begins to be displayed at startindex, and stops being displayed
%at stopindex, and is displayed every 3 cells.

counter = 1;
numGeneList = ((stopindex-startindex)/3) + 1;
GeneList = cell(1,numGeneList);

for i = startindex:3:stopindex
    GeneList{1,counter} = extraction{1,1}{i,1};
    counter = counter + 1;
end

for i = 1:length(GeneList)
   for j = 1:length(header)
      if strfind(header{1,j},GeneList{1,i})
         GeneList{1,i} = header{1,j};
      end
   end
end

%sort the output list in faux-alphabetical order
GeneList = sort(GeneList);

fclose(fid);

else
   GeneList = -1; 
end

end