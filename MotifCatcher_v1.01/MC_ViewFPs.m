function MC_ViewFPs(Directory)
%This function views all generated FPs for a particular directory.

loadfile = strcat(Directory,'/DataSetProfile.mat');
S = load(loadfile);

for i = 1:length(S.DataSetProfile.Families)
    file = char(strcat(Directory,'/Family',num2str(i),'/meme.html'));
    cmd = ['open ' file ];
    system(cmd);   
end

end