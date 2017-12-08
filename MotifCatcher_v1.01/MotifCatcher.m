function MotifCatcher
% An introductory GUI welcomes the user to MotifCatcher, and allows he or
% she to select an appropriate task.
%
% To use MotifCatcher, please make sure you have the following programs
% installed and operational:
%
% (1) MEME (including MEME.bin, fastagetmarkov.bin, and MAST.bin)
%     You will need to provide the full system path.
%
% (2) STAMP
%     You will need to provide the full system path.
%
% (3) SetPartFolder
%     A folder of convenient Set Partition functions developed by Bruno
%     Luong, available on the MATLAB file exchange.  
%
%     Please ensure that this folder is saved on your system path.

%If the user makes no selection, the program exits without further action.
TaskNumber = 7;

% ----------------------------------------------------------------------- %
% --- Construct the components ------------------------------------------ %
% ----------------------------------------------------------------------- %

%base figure
fh = figure('Visible','on','Name','MotifCatcher',...
           'Position',[560,300,700,500]);
       
%Panels
% - banner -------------------------------------------------------------- %
ph1 = uipanel('Parent',fh,...
        'Position',[0.04 .80 .76 .16]);

%define axes
ah1 = axes('Parent',ph1,'Position',[0 0 1 1]);

%load image, process
%logo = imread('MotifCatcher_TitleLogo.png');
logo = imread('MotifCatcherTitleLogo.tif');
image(logo,'Parent',ah1);         
         
% - logo ---------------------------------------------------------------- %
ph2 = uipanel('Parent',fh,...
             'Position',[.84 .80 .12 .16]);    
         
ah2 = axes('Parent',ph2,'Position',[0 0 1 1]);

%load image, process
%logo = imread('MC_Logo_MotifCatcher.png');
logo = imread('DreamCatcherLogo.tif');
image(logo,'Parent',ah2);

% - Selection Radio buttons --------------------------------------------- %
ph3 =   uipanel('Parent',fh,'Title',...
     'What would you like MotifCatcher to do for you today?','FontSize',...
     14,'Position',[0.04 0.04 .92 .72]);

%Create the button group.
h = uibuttongroup('visible','off','Position',[0 0 1 1],'Parent',ph3);

%displacement coefficient
a = 0.05;

%button group: select a job
u1 = uicontrol('parent',h,'Style','Radio',...
    'String','Create data profile for an input data set (whole pipeline)',...
    'Units','normalized',...
    'Position',[.05 .90-a .90 .10],'HandleVisibility','off');

u2 = uicontrol('parent',h,'Style','Radio',...
    'String','Build a set of related subsets from an input data set',...
    'Units','normalized',...
    'Position',[.05 .80-a .90 .10],'HandleVisibility','off');

u3 = uicontrol('parent',h,'Style','Radio',...
    'String','Create a motif tree from a set of related subsets',...
    'Units','normalized',...
    'Position',[.05 .70-a .90 .10],'HandleVisibility','off');

u4 = uicontrol('parent',h,'Style','Radio',...
    'String','Determine families and familial profiles from a motif tree',...
    'Units','normalized',...
    'Position',[.05 .60-a .90 .10],'HandleVisibility','off');

u5 = uicontrol('parent',h,'Style','Radio',...
    'String','Build a motif map from a set of familial profiles',...
    'Units','normalized',...
    'Position',[.05 .50-a .90 .10],'HandleVisibility','off');

u6 = uicontrol('parent',h,'Style','Radio',...
    'String','Evaluate motif co-localizations and co-occurrences in a motif map',...
    'Units','normalized',...
    'Position',[.05 .40-a .90 .10],'HandleVisibility','off');

u7 = uicontrol('parent',h,'Style','Radio',...
    'String','Exit MotifCatcher',...
    'Units','normalized',...
    'Position',[.05 .30-a .90 .10],'HandleVisibility','off');

%tag each button appropriately
set(u1,'Tag','radiobutton1');
set(u2,'Tag','radiobutton2');
set(u3,'Tag','radiobutton3');
set(u4,'Tag','radiobutton4');
set(u5,'Tag','radiobutton5');
set(u6,'Tag','radiobutton6');
set(u7,'Tag','radiobutton7');

% Initialize some button group properties. 
set(h,'SelectionChangeFcn',@selcbk);
set(h,'SelectedObject',[]);  % No selection
set(h,'Visible','on');
 
%set all text-handles to same font.
set(ph3,'FontName','Handwriting - Dakota');
set(u1,'FontName','American Typewriter');
set(u2,'FontName','American Typewriter');
set(u3,'FontName','American Typewriter');
set(u4,'FontName','American Typewriter');
set(u5,'FontName','American Typewriter');
set(u6,'FontName','American Typewriter');
set(u7,'FontName','American Typewriter');

%submit pushbutton
pb = uicontrol('Style', 'pushbutton', 'String', 'Submit',...
    'Units','normalized','Position', [.40 .1 .2 .1],'Parent',ph3);

set(pb,'Callback','uiresume(gcf)');

%selection submission
uiwait(gcf);
close(gcf);

%Perform encouraged task.
if TaskNumber == 7
    disp('goodbye')
else
    MC_MotifCatcherPipeline(TaskNumber);
end
    
% ----------------------------------------------------------------------- %
% --- Callbacks --------------------------------------------------------- %
% ----------------------------------------------------------------------- %

function selcbk(hObject,eventdata)
    %among possible courses of action to take in 'MotifCatcher', this sets
    %the proposed task number according to the user's choice.
    switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
        case 'radiobutton1' 
            %whole pipeline
            TaskNumber = 1;

        case 'radiobutton2'
            %just build End States
            TaskNumber = 2;

        case 'radiobutton3'
            %analyze a library of End States
            TaskNumber = 3;

        case 'radiobutton4'
            %Compare multiple DataProfiles
            TaskNumber = 4;

        case 'radiobutton5' 
            TaskNumber = 5;

        case 'radiobutton6'
            TaskNumber = 6;
        
        case 'radiobutton7'
            TaskNumber = 7;
            
        otherwise
            %exit
            TaskNumber = 7;
    end
end

end