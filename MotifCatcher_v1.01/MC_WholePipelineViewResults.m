function Option = MC_WholePipelineViewResults
%description: following a whole pipeline run, you may review the results in
%the GUI tree viewer.
    Option = questdlg('Would you like to view the results in the GUI tree viewer?','Tree Viewer Option','Yes','No','No');
end