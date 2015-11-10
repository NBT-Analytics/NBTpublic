function nbt_list_biomarkers  (Info, Save_dir)

analysis_file = [Save_dir,'/',Info.file_name,'_analysis.mat'];
if exist(analysis_file)
    [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers(analysis_file);
else
    biomarker_objects = 'No biomarkers computed for this NBT file';
end
msgbox(biomarker_objects,'Biomarkers','modal')
