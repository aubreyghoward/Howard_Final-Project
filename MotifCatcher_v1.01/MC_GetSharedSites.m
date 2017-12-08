function Sites = MC_GetSharedSites(AllMotifsAndLocations,Threshold)
%This function creates a list of sequence entries from a MM-like structure 
%(AllMotifsAndLocations) that appear at least (FP frequency threshold) 
%percent of the time among all runs that are included in a given motif group.

Sites = [];

for i = 1:length(AllMotifsAndLocations)
    %each family from a given data set has a membership matrix.
    NumSites = 0;
    
    for j = 3:length(AllMotifsAndLocations{1,i}(:,1))
    %each row
    NonEmptySites = 0;
        for k = 2:length(AllMotifsAndLocations{1,i}(1,:))
            if ~isempty(AllMotifsAndLocations{1,i}{j,k})
                NonEmptySites = NonEmptySites+1;
            end
        end
        
        %if enough sites pass, note the regions
        if NonEmptySites/(length(AllMotifsAndLocations{1,i}(1,:))-1) >= Threshold
            NumSites = NumSites + 1;
            Sites{1,i}{NumSites,1} = AllMotifsAndLocations{1,i}{j,1};
        end
    end
end