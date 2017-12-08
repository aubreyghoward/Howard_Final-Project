function SearchStyle = MC_inputSearchStyle
%function: when gathering inputs, this block allows the user to specify a
%search style.

%Default setting:
SearchStyle = 3;

%base figure
fh = figure('Visible','on','Name','related subset determination protocol',...
           'units','normalized','Position',[0.4 0.6 0.2 0.2]);

a = 0.05;
       
%label for user-entry threshold
sth = uicontrol(fh,'Style','text',...
            'Fontsize',14,...
            'String','Related subset R determination protocol',...
            'Units','normalized',...
            'HorizontalAlignment','Left',...
            'Position',[.05 .90-a .90 .10]);     

% Create the button group.
h = uibuttongroup('visible','off','Position',[0 0 1 1],'Parent',fh);
       
b = 0.02;

%button group: select a job
u1 = uicontrol('parent',h,'Style','Radio',...
    'String','MEME ZOOPS MC Search',...
    'Units','normalized',...
    'Position',[.05 .70-a+b .90 .10],'HandleVisibility','off');

u2 = uicontrol('parent',h,'Style','Radio',...
    'String','Single MAST MC Search',...
    'Units','normalized',...
    'Position',[.05 .50-a+b .90 .10],'HandleVisibility','off');

u3 = uicontrol('parent',h,'Style','Radio',...
    'String','Iterative MEME/MAST MC Search',...
    'Units','normalized',...
    'Position',[.05 .30-a+b .90 .10],'HandleVisibility','off');

%tag each button appropriately
set(u1,'Tag','radiobutton1');
set(u2,'Tag','radiobutton2');
set(u3,'Tag','radiobutton3');

% Initialize some button group properties. 
set(h,'SelectionChangeFcn',@selcbk);
set(h,'SelectedObject',u3);  % No selection
set(h,'Visible','on');

%submit pushbutton
pb = uicontrol('Style', 'pushbutton', 'String', 'Submit',...
    'Units','normalized','Position', [.40 .05 .2 .15],'Parent',fh);

set(pb,'Callback','uiresume(gcf)');

%selection submission
uiwait(gcf);
close(gcf);


function selcbk(hObject,eventdata)
    %among possible courses of action to take in 'MotifCatcher', this sets
    %the proposed task number according to the user's choice.
    switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
        case 'radiobutton1' 
            %whole pipeline
            SearchStyle = 1;

        case 'radiobutton2'
            %just build End States
            SearchStyle = 2;

        case 'radiobutton3'
            %analyze a library of End States
            SearchStyle = 3;
    end
end


end