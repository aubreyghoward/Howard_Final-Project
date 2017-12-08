function MC_MakeFPs(AllMotifsAndLocations,FPdir,DataSetProfile,...
    SharedSitesThreshold)
%Description: This function creates FPs from the GUI tree viewer.

%import fasta file.
[SeqFileHeader Sequence] = fastaread(DataSetProfile.SeqFile);

%disable append-to-file warning
warning('off','Bioinfo:fastawrite:AppendToFile'); 

%start off by making a directory to contain all the FBP sequence.
FPseq_dir = strcat(FPdir,'/Sequences');
system(['mkdir ' FPseq_dir]);

%obtain sites
Sites = MC_GetSharedSites(AllMotifsAndLocations,SharedSitesThreshold);

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
    outputdir = strcat(FPdir,'/Family',num2str(i));
    cmd = ['mkdir ' outputdir];
    system(cmd);
    
    %map to correct bfile
    bfile = DataSetProfile.MEME_parameters.bfile;
       
    %input to meme program.
    %note that here we use 'oops' instead of 'zoops', this requires that
    %all input sites produce a motif.
    cmd = [DataSetProfile.ProgramLocations.MEME ' ' familyfile ' -minw ' num2str(DataSetProfile.MEME_parameters.MinWidth) ' -maxw ' num2str(DataSetProfile.MEME_parameters.MaxWidth) ' -' DataSetProfile.MEME_parameters.Alphabet ' -bfile ' bfile ' -mod oops -oc ' outputdir ' -nostatus -maxsize 1000000'];

    %option: search the reverse complement, or not.
    if DataSetProfile.MEME_parameters.RevComp == 1
       cmd = [cmd ' -revcomp']; 
    end
    
    %send to command line to create directories.
    system(cmd);
end

end