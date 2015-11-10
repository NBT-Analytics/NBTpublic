function LastUpdate=GetLog(BiomarkerObject)

LastUpdate = BiomarkerObject.LastUpdate;
disp('The Biomarker was last updated')
disp(LastUpdate)
disp('by')
disp(BiomarkerObject.ReseacherID)
end