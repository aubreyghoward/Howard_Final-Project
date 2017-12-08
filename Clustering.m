%Bioc 570 Final Project.
clear all
[num,txt,raw] = xlsread('matlab_clustering.xlsx',1);
[m,n] = size(num);%697 genes, 10 Liquid Killing conditions
[x,y] = size(txt);%checked the size of my txt array
conditionname= {'lk16','lk32','lk34','lk35','lk38','lk56','Phenanthroline','RPW',...
    'Hygromycin','Cadmium'};%Defines the names of each of my conditions 
                            %(eg. the columns of num and txt)
numoclust = 15;
%input for the number of clusters

ids = kmeans(num,numoclust);
figure(1); hold on;
for ii = 1:numoclust
    inds = ids == ii;
    subplot(3,5,ii);
    plot(1:n,mean(num(inds,:),1),'.-','LineWidth',3,'Markersize',18);
    hold on;
    title([' Cluster ' int2str(ii) , ' | #genes: ' int2str(sum(inds))],'FontSize',9);
end
hold off;

% figure;hold on;
% for ii = 1:length(n);
%     scatter(1:length(num(:,1)),num(:,ii),4^2,ids,'filled');
% end
% hold off;
%%
clear conditionname z ii idscell sortedtxt idx

% z = 0;
% for ii = 1:length(ids)
%     if ids(ii,:) == 15
%         z = z+1;
%     end
% end

idscell = num2cell(ids);
sortedtxt = [idscell txt];

[ranks_ordered, idx] = sort(cell2mat(sortedtxt(:,1)));
sortedtxt = sortedtxt(idx,:);

%Make a structure for my gene informaiton.
field1 = 'id';                 value1 = {sortedtxt{:,1}};
field2 = 'geneName';           value2 = {sortedtxt{:,2}};
field3 = 'GenbankID';          value3 = {sortedtxt{:,3}};
field4 = 'GOterms';            value4 = {sortedtxt{:,4}};
field5 = 'GeneSequence';       value5 = cell([1,length(sortedtxt)]);
field6 = 'Promotor';           value6 = cell([1,length(sortedtxt)]);
field7 = 'PromotorComplement'; value7 = cell([1,length(sortedtxt)]);
Kgroup = struct(field1,value1,field2,value2,field3,...
    value3,field4,value4,field5,value5,field6,value6,field7,value7);
clear field1 field2 field3 field4 field5 field6 field7
clear value1 value2 value3 value4 value5 value6 value7

%read in the C. elegans Genome

gunzip('caenorhabditis_elegans.PRJNA13758.WBPS9.genomic.fa.gz');
%[headers, totalgenome] = fastaread('GCA_0000029853_Celegans.fasta');
[headers, totalgenome] = fastaread('caenorhabditis_elegans.PRJNA13758.WBPS9.genomic.fa');
totalgenome = [totalgenome{1,1:end}];
totalgenome = [totalgenome seqcomplement(totalgenome)];

%%
%Find the starting position of each gene and gets the promotor region (1000
%bp upstream of start). 
for q = 1:length(sortedtxt)
    disp(['Getting gene data for : ' num2str(q)])
    Kgroup(q).GeneSequence = getgenbank(Kgroup(q).GenbankID,'SEQUENCEONLY',true);
    geneindx = strfind(totalgenome,Kgroup(q).GeneSequence(1,1:14));
%Note on unique nucleotide sequences: Assuming a C. elegans genome size of
%100,258,171 bp, we can calculate the number of bp required to make a
%unique sequence as n = log4(genomesize) or n = 13.7. This is the minimum 
%number of base pairs needed to be uniqie in the total geneome size. 
%Moveing forward I will use 14 bp as my representative unique sequence, to 
%insure I will get the gene of intrest.

    if geneindx-1000 <= 0
        Kgroup(q).Promotor = totalgenome(0:geneindx);
        Kgroup(q).PromotorComplement = seqcomplement(totalgenome(0:geneindx));
        pause(2);
    else
        Kgroup(q).Promotor = totalgenome(geneindx-1000:geneindx);
        Kgroup(q).PromotorComplement = seqcomplement(totalgenome(geneindx-1000:geneindx));
        pause(2);
    end
end
%%
%Find and recored # of esre motifs
esre = 'tctgcgtctct';
esre = upper(esre);
count = 0; foundPromos = 0; groupnum = 1;
for q = 2:length(Kgroup)
        chck = strfind(Kgroup(q).Promotor,esre);%count esre Motifs
        if isempty(chck) < 1 
            count = count+1;
        end

        if isempty(Kgroup(q).Promotor) ~= 1 %find empty promotor regions
            foundPromos = foundPromos + 1;
        end
    if Kgroup(q).id == Kgroup(q-1).id %Assign counts to groups
        GroupCount(groupnum) = count;
    else
        groupnum = groupnum+1;
        GroupCount(groupnum) = count - GroupCount(groupnum-1);
        count = GroupCount(groupnum)
    end
end
TotalESRE = length([strfind(totalgenome,esre)]'); %Count all esre motifs



%%

%This code was in development in an attempt to compare each of the motifs 
%to each other to search for common elements. I ran out of time during the
%semester to finish this, but have plans to continue to explore this as
%well as other methods, including incorporating the blastlocal search into
%my program. This code is not addreddesed in depth in the paper. 
q = 1;
count = 1;
for ii = 2:length(Kgroup)
    ii
    if Kgroup(ii).id == Kgroup(ii-1).id
        count = count+1
        indexofgroups(q) = count
    else
        indexofgroups(q) = count
        count = 1;
        q = q+1
    end
end
%%
%Make a structure to save the motif data
field1 = 'KgroupID';                value1 = cell(10^5,1);
field2 = 'Motifpool';               value2 = cell(10^5,1);
field3 = 'FrequencyScore';          value3 = cell(10^5,1);
field4 = 'Motifs';                  value4 = cell(10^5,1);
MotifData = struct(field1,value1,field2,value2,field3,value3,field4,value4);
clear field1 field2 field3 field4; clear value1 value2 value3 value4;
%%


q = 1;
n = 1;

for i = 1:length(indexofgroups)
    for ii = n:indexofgroups(q)
        if ii == n
        [nmersFound, freqDiffSorted] = motiffinder(Kgroup(ii).Promotor,[Kgroup(ii+1:indexofgroups(i)).Promotor],14)
        %nxtln = 
        else
        [nmersFound, freqDiffSorted] = motiffinder(Kgroup(ii).Promotor,...
        [Kgroup(n:ii-1).Promotor Kgroup(ii+1:indexofgroups(i)).Promotor],14)
        %struct
        end
    end
    q = q+1;
    n = indexofgroups(q);
end



disp('done')