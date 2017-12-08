function Families = MC_GetFamilies(STAMPTreeClustersfile)
%This function retrieves families of End States from STAMP's Clustering
%Scheme.
%

%extract from file
fid = fopen(STAMPTreeClustersfile);
extraction = textscan(fid,'%s');
fclose(fid);

%initialize
NumClusters = 0;
ClusterSpots = [];

%find all entries in the file that display a list of clusters.
for i = 1:length(extraction{1,1})
   if strmatch('Cluster_Members:',extraction{1,1}{i,1},'exact')
        NumClusters = NumClusters + 1;
        ClusterSpots = [ClusterSpots i];
   end
end

Families = cell(length(ClusterSpots),1);

for i = 1:length(ClusterSpots)
    counter = 1;
    AllWritten = false;
    
    while(AllWritten == false)
        
        FamNum = sscanf(strtok(extraction{1,1}{ClusterSpots(i)+counter},'v'),'Run%d');

        Families{i,1} = [Families{i,1} FamNum];
        
        %stop adding families to clusters either when (1) end of whole file
        % or (2) end of family list
        if ClusterSpots(i) + counter >= length(extraction{1,1})
            break;
            %exit the while loop at the end of the file
        elseif isempty(strfind(extraction{1,1}{ClusterSpots(i)+counter+1},'Run'))
           AllWritten = true; 
        end
        
        %increment counter for next entry.
        counter = counter + 1;
        
    end
end

%sort families in ascending order.
for i = 1:length(Families)
   Families{i,1} = sort(Families{i,1}); 
end

end