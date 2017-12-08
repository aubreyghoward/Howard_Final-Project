function MC_TreeWithClusters(phytree,TreeDir)
% This function allows for interactive user-control of phytree, and draw
% clusters the smart way.

% ----------------------------------------------------------------------- %
% --- Initializations --------------------------------------------------- %
% ----------------------------------------------------------------------- %

%disable append-to-file warning
warning('off','Bioinfo:fastawrite:AppendToFile'); 

% ----------------------------------------------------------------------- %
% --- Construct the components ------------------------------------------ %
% ----------------------------------------------------------------------- %

%base figure
fh = figure('Visible','on','Name','Motif Tree',...
           'Position',[1300,600,650,650]);
       
%Panels
% - banner -------------------------------------------------------------- %
ph1 = uipanel('Parent',fh,...
             'Position',[0.04 .85 .77 .11]);

ah1 = axes('Parent',ph1,'Position',[0 0 1 1]);

%load image, process
%logo = imread('MotifCatcher_TitleLogo.png');
logo = imread('MotifCatcherTitleLogo.tif');
image(logo,'Parent',ah1);         
         
% - logo ---------------------------------------------------------------- %
ph2 = uipanel('Parent',fh,...
             'Position',[.85 .85 .11 .11]);     
         
ah2 = axes('Parent',ph2,'Position',[0 0 1 1]);

%load image, process
%logo = imread('MC_Logo_MotifCatcher.png');
logo = imread('DreamCatcherLogo.tif');
image(logo,'Parent',ah2);

% - Clustering/FP generation ------------------------------------------ %
b = 0.08;

ph3 =   uipanel('Parent',fh,'Title',...
    'Family and Familial Profile (FP) Computation','FontSize',...
    14,'Position',[0.04 0.04 .92 .72+b]);

set(ph3,'FontName','Handwriting - Dakota');

%error-catching: empty tree
if ~isempty(phytree)
    h = plot(phytree);
else
    disp('The Tree file is empty. Returning to main menu.');
    close(gcf)
    MotifCatcher;
end

% - display clusters on phytree ----------------------------------------- %

c = 0.06;
%label for user-entry threshold
sth = uicontrol(ph3,'Style','text',...
                'Fontsize',12,...
                'String','Clustering threshold',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.06 .85+c .52 .08]);

%user-specified threshold value
eth = uicontrol(ph3,'Style','edit',...
                'String','0',...
                'Units','normalized',...
                'Fontsize',16,'Position',[.05 .79+c .50 .10]);
            
set(eth,'FontName','Courier');

%cluster computation button.
pbh = uicontrol(ph3,'Style','pushbutton',...
                'String','Compute Families',...
                'Units','normalized',...
                'Position',[.55 .79+c .40 .10]);

%push button shows clusters in tree plot.
set(pbh,'Callback',@ComputeClusters);

% - export clusters to structure ---------------------------------------- %

%label for user-entry export structure
sthe = uicontrol(ph3,'Style','text',...
                'Fontsize',12,...
                'String','Preferred Family Export Directory (whole path)',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.06 .64+c .52 .10]);

%user-specified export location
ethe = uicontrol(ph3,'Style','edit',...
                'String',TreeDir,...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Fontsize',10,'Position',[.05 .60+c .90 .10]);
            

pbec = uicontrol(ph3,'Style','pushbutton',...
                'String','Export Families',...
                'Units','normalized',...
                'Position',[.05 .50+c .40 .10]);

%push button appends DataSetProfile structure with the clustered
%information.
set(pbec,'Callback',@ExportClusters);

% - view ES members in cluster group ------------------------------------ %
sthvc = uicontrol(ph3,'Style','text',...
                'Fontsize',12,...
                'String','Family',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.55 .475+c .10 .10]);

ethvc = uicontrol(ph3,'Style','edit',...
                'String','1',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Fontsize',16,'Position',[.65 .50+c .08 .10]);

pbvc = uicontrol(ph3,'Style','pushbutton',...
                'String','View Ri',...
                'Units','normalized',...
                'Position',[.73 .50+c .22 .10]);

set(ethvc,'FontName','Courier');
set(pbvc,'Callback',@DisplayES);
            
% - compute FP, create FP directory --------------------------------- %

%determine default
[junk root] = strtok(fliplr(TreeDir),'/');
root = fliplr(root);
root = strcat(root,'FP');

%label for user-entry export structure
sthc = uicontrol(ph3,'Style','text',...
                'Fontsize',12,...
                'String','Preferred FP folder (whole path)',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.06 .36+c .52 .10]);

%user-specified export location
ethc = uicontrol(ph3,'Style','edit',...
                'String',root,...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Fontsize',10,'Position',[.05 .32+c .90 .10]);

sthc = uicontrol(ph3,'Style','text',...
                'Fontsize',12,...
                'String','FP frequency threshold:',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.55 .21+c .15 .10]);            
            
ethss = uicontrol(ph3,'Style','edit',...
                'Fontsize',16,...
                'String','0.6',...
                'Units','normalized',...
                'HorizontalAlignment','Left',...
                'Position',[.70 .22+c .25 .10]);            

pbcp = uicontrol(ph3,'Style','pushbutton',...
                'String','Calculate FPs',...
                'Units','normalized',...
                'Position',[.05 .22+c .40 .10]);

set(ethss,'FontName','Courier');

            
%push button appends DataSetProfile structure with the clustered
%information.
set(pbcp,'Callback',@ComputeFPs);


% - show all FP families ---------------------------------------------- %

pbs = uicontrol(ph3,'Style','pushbutton',...
                'String','Display FPs',...
                'Units','normalized',...
                'Position',[.55 .16 .40 .10]);

set(pbs,'Callback',@ShowFPs);            
            

% - MotifMap-related computations --------------------------------------- %
pbmm = uicontrol(ph3,'Style','pushbutton',...
            'String','Create Motif Map',...
            'Units','normalized',...
            'Position',[.05 .16 .40 .10]);
        
set(pbmm,'Callback',@MakeMotifMap);            
                    
pbemm = uicontrol(ph3,'Style','pushbutton',...
            'String','Evaluate Motif Map',...
            'Units','normalized',...
            'Position',[.05 .05 .40 .10]);
        
set(pbemm,'Callback',@EvalMotifMap); 

% - Exit to main menu --------------------------------------------------- %

pbex = uicontrol(ph3,'Style','pushbutton',...
                'String','Return to Main Menu',...
                'Units','normalized',...
                'Position',[.55 .05 .40 .10]);          

set(pbex,'Callback','close(gcf); close(''all''); MotifCatcher');
            
% ----------------------------------------------------------------------- %
% --- Callbacks --------------------------------------------------------- %
% ----------------------------------------------------------------------- %

% ----------------------------------- %
% ---- Data Computation functions --- %
% ----------------------------------- %

function ComputeClusters(hObject,eventdata)
    
    disp('Processing request...');
    
    %define all global variables
    global LeafClusters ClusteringThreshold;
    global AllMotifsAndLocations Families R_dir;

    %retrieve Clustering Threshold value
    ClusteringThreshold = str2double(get(eth,'String'));
    
    %evaluate clusters
    [LeafClusters,NodeClusters] = ...
        cluster(phytree,ClusteringThreshold);
    
    disp(['found ' num2str(max(LeafClusters)) ' Clusters.']);
    
    cmap = colormap(lines);
    for k = 1:max(LeafClusters)
        set(h.BranchLines(NodeClusters == k),'Color',cmap(k,:))
    end

    %retrieve Structure containing all relevant information for Cluster
    %computation
    LoadStructure = strcat(TreeDir,'/DataSetProfile.mat');
    
    S = load(LoadStructure);
    
    disp('Computing variables necessary for R-associated motif display...');
    
    %Create clusters
    [Families AllMotifsAndLocations] = MC_MakeClusters(S.DataSetProfile,ClusteringThreshold);
    
    %retrieve R_dir
    file = strcat(TreeDir,'/DataSetProfile.mat');
    S = load(file);
    
    R_dir = char(S.DataSetProfile.Directories.RMEME);
    disp('Job successfully completed!');
end

%Create FP directory, compute clusters, families, and FPs, save struct
function ComputeFPs(hObject,eventdata)
    %start message
    disp('Processing request...');
    
    %create FP directory
    FPdir = get(ethc,'String');
    system(['mkdir ' FPdir]);
    
    %retrieve Clustering Threshold value
    global ClusteringThreshold

    %retrieve clusters
    global Families AllMotifsAndLocations;

    disp('Clusters successfully retrieved.');
    disp('Building FP profiles...');
    
    %obtain specifications for FP construction
    SharedSitesThreshold = str2double(get(ethss,'String'));
    
    %retrieve Structure containing all relevant information for FP build
    LoadStructure = strcat(TreeDir,'/DataSetProfile.mat');
    
    S = load(LoadStructure);
    
    %build FPs
    MC_MakeFPs(AllMotifsAndLocations,FPdir,S.DataSetProfile,...
        SharedSitesThreshold)
    
    %create new output for FP folder.
    DataSetProfile = struct();
    
    %first, record all repeated parameters
    DataSetProfile.SeqFile = S.DataSetProfile.SeqFile;
    DataSetProfile.Directories = S.DataSetProfile.Directories;
    DataSetProfile.MEME_parameters = S.DataSetProfile.MEME_parameters;
    DataSetProfile.R_parameters = S.DataSetProfile.R_parameters;
    DataSetProfile.ProgramLocations = S.DataSetProfile.ProgramLocations;
    DataSetProfile.MotifTree_parameters = S.DataSetProfile.MotifTree_parameters;
    DataSetProfile.Tree = S.DataSetProfile.Tree;
    DataSetProfile.DirectoryList = S.DataSetProfile.DirectoryList;
    
    %add all additional parameters
    DataSetProfile.Clustering_parameters.ClusteringThreshold = ClusteringThreshold;
    DataSetProfile.Clustering_parameters.SharedSitesThreshold = SharedSitesThreshold;
    DataSetProfile.Directories.FP = FPdir;
    
    %add output cluster information
    DataSetProfile.Families = Families;
    DataSetProfile.AllMotifsAndLocations = AllMotifsAndLocations;
    
    %save variables to appropriate structure.
    filename = strcat(get(ethc,'String'),'/DataSetProfile.mat');
      
    save(filename,'DataSetProfile');
    
    disp('Job successfully completed!');
end

% ----------------------------------- %
% ---- Display Results functions ---- %
% ----------------------------------- %

function ShowFPs(hObject,eventdata)
    
    %retrieve appropriate directory
    Directory = get(ethc,'String');
    
    %view FPs.
    MC_ViewFPs(Directory); 
end

function DisplayES(hObject,eventdata)
    
    global AllMotifsAndLocations Families R_dir;
    
    %retrieve RankValue
    RankValue = str2double(get(ethvc,'String'));

    %view family members
    MC_ViewFamilyMembers(AllMotifsAndLocations,Families,RankValue,R_dir)

end

%export clusters into the directory containing Motif Tree.
function ExportClusters(hObject,eventdata)
    %start message
    disp('Processing request...');

    %retrieve computed cluster variables
    global AllMotifsAndLocations Families LeafClusters ClusteringThreshold;
    
    %save variables to appropriate structure.
    filename = strcat(get(ethe,'String'),'/Clusters_CT_',get(eth,'String'),'.mat');
      
    save(filename,'ClusteringThreshold','Families','AllMotifsAndLocations');
    
    disp([num2str(max(LeafClusters)) ' Clusters successfully exported.']);
    disp('Job successfully completed!');
end

% ----------------------------------- %
% -- MotifMap-related computations -- %
% ----------------------------------- %

function MakeMotifMap(hObject,eventdata)
    disp('Processing request...');
    
    %retrieve FPdir
    FPdir = get(ethc,'String');
    
    %retrieve DataSetProfile
    filename = strcat(FPdir,'/DataSetProfile.mat');
    S = load(filename);

    MotifMap = MC_MakeMotifMap(S.DataSetProfile.Directories,...
        S.DataSetProfile.SeqFile,S.DataSetProfile.MEME_parameters.RevComp);

    %load into new structure
    DataSetProfile = S.DataSetProfile;
    DataSetProfile.MotifMap = MotifMap;

    %remove old version and upload new version.
    system(['rm ' filename]);
    save(filename,'DataSetProfile');

    disp('Job successfully completed!');
end

function EvalMotifMap(hObject,eventdata)
    disp('Processing request...');
    
    %retrieve FPdir
    FPdir = get(ethc,'String');
    
    %retrieve DataSetProfile
    filename = strcat(FPdir,'/DataSetProfile.mat');
    S = load(filename);

    %evaluate CoOccurrences, CoLocalizations, and CoVals
    [CoOccurrences CoLocalizations CoVals] = ...
        MC_CompareOccurrenceAndLocalization(S.DataSetProfile.MotifMap);

    %load into new structure
    DataSetProfile = S.DataSetProfile;
    DataSetProfile.CoOccurrences = CoOccurrences;
    DataSetProfile.CoLocalizations = CoLocalizations;
    DataSetProfile.CoVals = CoVals;

    %remove old version and upload new version.
    system(['rm ' filename]);
    save(filename,'DataSetProfile');
    
    disp('Job successfully completed!');
end

end