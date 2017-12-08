function Motif = MC_GetMotif(file)
%This function extracts a motif from a given meme.txt file.
%
%Inputs:
%   file:
%       meme.txt outputfile
%
%Outputs:
%   motif:
%       double array of motif, nx4, n = length of motif.

%perform file extraction
fid = fopen(file,'r');
extraction = textscan(fid,'%s');
fclose(fid);

   %determine range of positition-specific probability matrix
   for j = 1:length(extraction{1,1})-4
        %revcomp version
        if ~isempty(strmatch(extraction{1,1}{j,1},'Motif')) && ...
                ~isempty(strmatch(extraction{1,1}{j+1,1},'1')) && ...
                ~isempty(strmatch(extraction{1,1}{j+2,1},'position-specific')) &&...
                ~isempty(strmatch(extraction{1,1}{j+3,1},'probability')) && ...
                ~isempty(strmatch(extraction{1,1}{j+4,1},'matrix'))

            Width = str2double(extraction{1,1}{j+11}); %width of matrix
            Startlook = j+16; %first 'A'
            Stoplook = Startlook + (4*Width) - 1; %last 'T'
        end
        
   end
   
%initialize the motif matrix.
Motif = zeros(Width,4);
counter = 0;

   for i = Startlook:Stoplook

       %increment row counter
       if mod(i-Startlook,4) == 0
           counter = counter + 1;
       end

           %Determine character
           if mod(i-Startlook,4) == 0 %A
                 EntryCol = 1;
           elseif mod(i-Startlook,4) == 1 %C
               EntryCol = 2;
           elseif mod(i-Startlook,4) == 2 %G
               EntryCol = 3;
           else %T
                 EntryCol = 4;
           end

           %Write to output matrix
           Motif(counter,EntryCol) = str2double(extraction{1,1}{i,1});

   end 
end
