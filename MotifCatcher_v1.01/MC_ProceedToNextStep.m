function Option = MC_ProceedToNextStep
%description: GUI dialog box, ask user if they would like to continue to
%the next step in the MotifCatcher pipeline
    Option = questdlg('Would you like to proceed to the next step?','Continue Pipeline Option','Yes','No','No');
end