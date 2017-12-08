function [SubsetList MEME_parameters]=...
    MC_MakeR(SeqFile,Directories,R_parameters,MEME_parameters,ProgramLocations)
%This function generates Ri according to one of the three R-determination
%protocols.
%
%--------------------------------------------------------------------------
%Inputs:
%
%   SeqFile:
%       input data set of sequences
%   Directories:
%       directories for output
%   R_parameters:
%       details for creating an 'R'
%   MEME_parameters:
%       details for motif search
%   ProgramLocations:
%       location of MEME and MAST on system

%Outputs:
%   SubsetList:
%       A single Ri.  All other outputs created implicitly
%--------------------------------------------------------------------------

% -------- Initialize file locations ------------------------------------ %

%disable append-to-file warning
warning('off','Bioinfo:fastawrite:AppendToFile'); 

%import sequences
[header sequence] = fastaread(SeqFile);

%if a background file is not provided, create one from the input data set.
if isempty(MEME_parameters.bfile)
    
    %determine total number of characters in the whole dataset.  This value is
    %used to decide what order of background to use.
    TotalCharacters = 0;
    for i = 1:length(sequence)
        TotalCharacters = TotalCharacters + length(sequence{1,i});
    end

    %determine order of background file based on the total size of all input
    %sequences.
    if TotalCharacters >= 2560
        order = ' 3 ';
    elseif TotalCharacters > 1000
        order = ' 2 ';
    elseif TotalCharacters > 500
        order = ' 1 ';
    else
        order = ' 0 ';
    end

    %Create background file for meme analysis
    bfile = strcat(Directories.RMEME,'/bfile.model');
    cmd = strcat(ProgramLocations.FastaGetMarkov,' -m ', order, ' < ', SeqFile, ' > ',bfile);

    MEME_parameters.bfile = bfile;

    system(cmd);
    
end

for i = 1:R_parameters.Seeds
    
% -------- Generate a random seed --------------------------------------- %

%generate a random permutation
RP = randperm(length(header));

%from these randomly organized numbers, select as many as needed to build a
%subset.
SubsetNums = RP(1:R_parameters.SeedSize);

%build an initial list of genes.
%each cell contains the genes used for that particular run.
%the subset List is rebuilt for every run.
SubsetList = [];

for j = 1:length(SubsetNums)
    SubsetList{1,1}{1,j} = header{1,SubsetNums(j)};
end

% -------- initializations ---------------------------------------------- %
iterations = 0;
ClusterCompleted = false;

% -------- Iteratively re-cluster --------------------------------------- %
    while(ClusterCompleted == false)

% -------- Extract sequences, write to files ---------------------------- %
  
        %check to see that the .fasta files contains enough sequences for
        %MEME to run.  If so, build the file and move on.
        if length(SubsetList{1,iterations+1}) >= 2
           
            %make output file.
            filetitle = strcat(Directories.RSeqs,'/Seed',num2str(i),'v',num2str(iterations),'.fasta');
            for j = 1:length(SubsetList{1,iterations+1})

                %find sequence matching this header.
                for  q = 1:length(header)
                    
                   if ~isempty(strmatch(header{1,q},SubsetList{1,iterations+1}{1,j}))
                         %optional print statements
                         %disp(['j=' num2str(j) ': ' SubsetList{1,iterations+1}{1,j}])
                         %disp(['q=' num2str(q) ': ' header{1,q}])              
                      fastawrite(filetitle,SubsetList{1,iterations+1}{1,j},sequence{1,q});
                   end
                end
                
            end
            
            %MEME analysis
            %direct the meme program to run according to input parameters.
            memeout = strcat(Directories.RMEME,'/Seed',num2str(i),'v',num2str(iterations));
            cmd = [ProgramLocations.MEME ' ' filetitle ' -minw ' num2str(MEME_parameters.MinWidth) ' -maxw ' num2str(MEME_parameters.MaxWidth) ' -' MEME_parameters.Alphabet ' -bfile ' MEME_parameters.bfile ' -mod zoops -oc ' memeout ' -nostatus -maxsize 1000000'];
            
            %option: search the reverse complement, or not.
            if MEME_parameters.RevComp == 1
               cmd = [cmd ' -revcomp']; 
            end
            
            system(cmd); %send to command line
            
            % a simple ZOOPs search completes a run for SearchStyle 1.
            % ZOOPS -> MAST -> ZOOPS again is complete for SearchStyle 2.
            % the iterative process (until convergence) is the default,
            % which continues
            if R_parameters.SearchStyle == 1
                break;
            elseif R_parameters.SearchStyle == 2 && iterations == 1
                break;
            end
            
            %MAST analysis
            mastinputfile = strcat(memeout,'/meme.txt');

            cmd = [ProgramLocations.MAST  ' ' mastinputfile ' ' SeqFile ' -oc ' memeout ' -nostatus -nohtml -bfile ' MEME_parameters.bfile ' -ev ' num2str(MEME_parameters.MastThreshold)];

            %option: search for reverse compliment, or not.
            if MEME_parameters.RevComp == 0
                cmd = [cmd ' -norc'];
            end
            
            system(cmd); %send to command line
        
            
            %depending on the variety of search, the user may call for
            %different outputs.

            Res = MC_GetSubsetList(memeout,header);
            
            if iscell(Res) %check for missing MAST file
            SubsetList{1,iterations+2} = Res;
            
            %check for empty MAST-searches; in this case just revert to
            %previous.
            if isempty(SubsetList{1,iterations+2}) || ...
                    length(SubsetList{1,iterations+2}) == 1
               SubsetList{1,iterations+2} = SubsetList{1,iterations+1};
               ClusterCompleted = true;
               break;
            end
            
            %see if newest gene list is a repeat
            for j = 1:length(SubsetList)
                for k = 1:j-1
                   if isequal(sort(SubsetList{1,j}),sort(SubsetList{1,k}))
                       ClusterCompleted = true;
                       break;
                   end
                end
            end
            
            %increment the iteration number
            iterations = iterations + 1;
            
            else %exit the loop
               ClusterCompleted = true;
            end
        end

    end

    %optional print statement    
    disp(['Related subset ' num2str(i) ' determined.']);
end    

end