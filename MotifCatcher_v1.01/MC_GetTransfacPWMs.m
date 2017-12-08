function [EmptyFlag DirectoryList] = MC_GetTransfacPWMs(DirectoryList,outputfile,Directories,Clustering_parameters)
%Description:
%   This function retrieves the Ri-associated motifs (PWMs), and formats
%   them in Transfac format, so they may be processed by the STAMP
%   platform.

%preset: EmptyFlag is set to true.
EmptyFlag = true;

%Initialize EList
EList = [];

%The initial DirectoryList is all directories; this is trimmed down to be
%only the directories used for motif-construction.
NumAccepted = 0;
EListCandidate = 0;

for i = 1:length(DirectoryList)
    
   %retrieve meme output file. 
   file = strcat(Directories.RMEME,'/',char(DirectoryList{1,i}),'/meme.txt'); 
    
   %extract information from meme output file.
   fid = fopen(file,'r');
   extraction = textscan(fid,'%s');
   fclose(fid);
   
   %create a dummy Eval, in the case that no PWM exists for this motif.
   Eval = 1e20;
   
   %retrieve PWM coordinates from extraction.
   for j = 1:length(extraction{1,1})-8
        if ~isempty(strmatch(extraction{1,1}{j,1},'letter-probability')) && ...
                ~isempty(strmatch(extraction{1,1}{j+1,1},'matrix:')) && ...
                ~isempty(strmatch(extraction{1,1}{j+2,1},'alength=')) &&...
                ~isempty(strmatch(extraction{1,1}{j+4,1},'w=')) && ...
                ~isempty(strmatch(extraction{1,1}{j+6,1},'nsites=')) &&...
                ~isempty(strmatch(extraction{1,1}{j+8,1},'E='))

            %determine the E-value for the motif associated with this R.
            Eval = str2double(extraction{1,1}{j+9}); 
        end          
   end
   
   %if the determined Eval is not the dummy Eval, note this value.
   if Eval ~= 1e20
       
       EListCandidate = EListCandidate + 1;
   
       %Note the name and E-value of this motif.
       EList{EListCandidate,1} = char(DirectoryList{1,i});
       EList{EListCandidate,2} = Eval;

       %incrememnt the number of accepted (by E-value criterion) R.
       if Eval <= Clustering_parameters.EValThreshold
            NumAccepted = NumAccepted + 1;
       end

   end
end

%retrieve relevant E-value Ri.
if ~isempty(EList)

    %valid R were discovered!
    EmptyFlag = false;
    
    %sort the E-values into ascending order (best matches near the top)
    EList = sortrows(EList,2);

    %revise the Directory List to include only the appropriate R PWMs.
    if NumAccepted > Clustering_parameters.MaxR
        DirectoryList = EList(1:Clustering_parameters.MaxR,1)';
    else
        DirectoryList = EList(1:NumAccepted,1)';
    end

    %using the corrected DirectoryList, extract the appropriate files.
    for i = 1:length(DirectoryList)

       %retrieve meme output file. 
       file = strcat(Directories.RMEME,'/',DirectoryList{1,i},'/meme.txt'); 

       %extract information from meme output file.
       fid = fopen(file,'r');
       extraction = textscan(fid,'%s');
       fclose(fid);

       %retrieve PWM coordinates from extraction.
       for j = 1:length(extraction{1,1})-8
            if ~isempty(strmatch(extraction{1,1}{j,1},'letter-probability')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+1,1},'matrix:')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+2,1},'alength=')) &&...
                    ~isempty(strmatch(extraction{1,1}{j+4,1},'w=')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+6,1},'nsites=')) &&...
                    ~isempty(strmatch(extraction{1,1}{j+8,1},'E='))

                MatStart = j + 10;
                Sites = str2double(extraction{1,1}{j+7});

            end          

            if ~isempty(strmatch(extraction{1,1}{j,1},'Motif')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+1,1},'1')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+2,1},'regular')) && ...
                    ~isempty(strmatch(extraction{1,1}{j+3,1},'expression'))
                MatStop = j - 3;

            end
       end

       %write the PWM to the output file.
       fid = fopen(outputfile,'a');

       %header
       fprintf(fid,'DE\t%s\n',DirectoryList{1,i});

       %matrix
       PosCounter = -1;
       for j = MatStart:4:MatStop

           %record the position counter - start counting at 0
           PosCounter = PosCounter + 1;

           %columns are frequencies, assembled from the number of sites.
           col1 = round(str2double(extraction{1,1}{j,1})*Sites);
           col2 = round(str2double(extraction{1,1}{j+1,1})*Sites);
           col3 = round(str2double(extraction{1,1}{j+2,1})*Sites);
           col4 =round(str2double(extraction{1,1}{j+3,1})*Sites);

           fprintf(fid,'%d\t%d\t%d\t%d\t%d\n',PosCounter,col1,col2,col3,col4);

       end

       %footer
       fprintf(fid,'XX\n');

       %close file.
       fclose(fid);
       
    end

end

end