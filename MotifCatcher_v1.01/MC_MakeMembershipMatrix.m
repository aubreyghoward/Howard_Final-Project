function MM = MC_MakeMembershipMatrix(InputSet,SeqFileHeader,RevComp)
%This function produces a membership matrix for cases where top motifs are
%determined by direct motif comparison (and clustering).
%
%Inputs:
%   InputsSet:
%       cell array of MEME output directories (whole path)
%   SeqFileHeader:
%       .fasta file of all sequences in the superset.
%
%Ouputs:
%   MM:
%       merged membership matrix
%   MotifLengths:
%       length of motifs, ordered as same as InputSet.
%
%Algorithm:
%   (1) Extract all information from all directories in input set, and
%       create a miniature membership matrix for each set. 
%   (2) Merge all sites from each directory into a single membership
%       matrix.
%   (3) sort membership matrix by multiplicity of sites included.

%(1) Extract all information each file in the InputSet
% ----------------------------------------------------------------------- %

%initalize extraction cell array, and MotifLengths.
mats = cell(1,length(InputSet));
MotifLengths = zeros(1,length(InputSet));

    for i = 1:length(InputSet)
           %determine the correct file to look for a particular site.
           file = strcat(InputSet{1,i},'/meme.txt');

           %pull information out of text file
           fid = fopen(file,'r');
           extraction = textscan(fid,'%s');
           fclose(fid);

           %determine range to search for sites, and find length of motif.
           for j = 1:length(extraction{1,1})-5
               
                %revcomp version
                if RevComp == 1
                    if ~isempty(strmatch(extraction{1,1}{j,1},'Sequence')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+1,1},'name')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+2,1},'Strand')) &&...
                            ~isempty(strmatch(extraction{1,1}{j+3,1},'Start')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+4,1},'P-value')) &&...
                            ~isempty(strmatch(extraction{1,1}{j+5,1},'Site'))

                        startlook = j + 9;
                        %display(startlook)
                    end
                else
                    if ~isempty(strmatch(extraction{1,1}{j,1},'Sequence')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+1,1},'name')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+2,1},'Start')) && ...
                            ~isempty(strmatch(extraction{1,1}{j+3,1},'P-value')) &&...
                            ~isempty(strmatch(extraction{1,1}{j+4,1},'Site'))

                        startlook = j + 9;
                        %display(startlook)
                        
                    end
                end           

                if ~isempty(strmatch(extraction{1,1}{j,1},'Motif')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+1,1},'1')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+2,1},'block')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+3,1},'diagrams'))
                    stoplook = j - 3;
                    %display(stoplook);
                end
                if ~isempty(strmatch(extraction{1,1}{j,1},'MOTIF')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+1,1},'1')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+2,1},'width')) && ...
                        ~isempty(strmatch(extraction{1,1}{j+3,1},'='))

                    MotifLength = str2double(extraction{1,1}{j+4});
                    MotifLengths(1,i) = MotifLength;
                    %display(MotifLength)
                end        
           end
    
           %Find all sites.  Look for key character ':' in the appropriate
           %range, or key character '[' in the appropriate range.
           counter = 0;
           Sites = [];

           for j = startlook:stoplook
              if   ~isempty(strfind(extraction{1,1}{j,1},'[')) || ...
                      ~isempty(strfind(extraction{1,1}{j,1},':')) || ...
                      ~isempty(strfind(extraction{1,1}{j,1},'|')) || ...
                      ~isempty(strfind(extraction{1,1}{j,1},'iY')) 
                  %the 'iY' search key was added for a yeast analysis, 'i' for intergenic, 'Y' for yeast
                  
                 counter = counter + 1;
                 Sites{counter,1} = extraction{1,1}{j,1}; %Site name
                 if RevComp == 1
                    Sites{counter,2} = extraction{1,1}{j+2,1}; %Start
                 else
                    Sites{counter,2} = extraction{1,1}{j+1,1}; 
                 end
              end
           end
           
           %Find the full name of each Site by searching for it in the
           %SeqFile.
           %
           %Note that here, (+) and (-)-strandedness are not considered;
           %this is because the interesting form of the motif might
           %actually be in reverse-compliment orientation.
           %
           %Instead, each motif length is evaluated by forward and reverse
           %compliment, at later stages of analysis.
           for k = 1:counter
               for j = 1:length(SeqFileHeader)
                   if strfind(SeqFileHeader{1,j},Sites{k,1})
                       
                       %record site
                       mats{1,i}{k,1} = SeqFileHeader{1,j};
                       
                       %record span of motif  
                       mats{1,i}{k,2} = [str2double(Sites{k,2}),str2double(Sites{k,2})+MotifLength-1];
                       
                   end
               end
           end
    end
    
%(2) Merge all extraced motifs into a single membership matrix
% ----------------------------------------------------------------------- %

    %initialize: MM takes the first input set.
    MM = mats{1,1};
    Motifs = length(MM(1,:)) - 1;
    Rows = length(MM(:,1));
    
    %incrementally add additional motifs to the MM structure.
    for i = 2:length(mats)
        
        Motifs = Motifs + 1; %each 'mat' group involves a new motif.
        
        for j = 1:length(mats{1,i});
            MakeNewRow = true;
            for k = 1:Rows
                if strmatch(mats{1,i}{j,1},MM{k,1})
                    
                    %instead of making a new row, write the information to
                    %the appropriate place.
                    MakeNewRow = false;
                    MM{k,Motifs+1} = mats{1,i}{j,2};
                end
            end
            
            if MakeNewRow == true
               
               %add a row
               Rows = Rows + 1;
               
               %write information to new row.
               MM{Rows,1} = mats{1,i}{j,1};
               MM{Rows,Motifs+1} = mats{1,i}{j,2};
            end
        end
    end
    
%(3) Sort sites by number of motifs contained
% ----------------------------------------------------------------------- %
    
    for i = 1:Rows-1
        for j = 1:Rows-1

            CurrentEmpty = 0;
            NextEmpty = 0;
            for k = 2:Motifs+1
                if ~isempty(MM{j,k})
                    CurrentEmpty = CurrentEmpty + 1;
                end
                if ~isempty(MM{j+1,k})
                    NextEmpty = NextEmpty + 1;
                end
            end
            
            if CurrentEmpty < NextEmpty
                % hold current in temp
                temp = MM(j,:);
                
                % write the old next into current
                MM(j,:) = MM(j+1,:);
                
                % the new next is the old current. 
                MM(j+1,:) = temp;
            end
        end
    end
end