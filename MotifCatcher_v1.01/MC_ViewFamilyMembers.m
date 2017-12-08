function MC_ViewFamilyMembers(AllMotifsAndLocations,Families,RankValue,R_dir)
%This function views all Ri within a single family.

for i = 1:length(cell2mat(Families(RankValue,1)))
    file = char(strcat(R_dir,'/',AllMotifsAndLocations{1,RankValue}(2,i+1),'/meme.html'));
    cmd = ['open ' file ];
    system(cmd);
end

end