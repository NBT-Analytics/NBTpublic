function nbt_plotICAwithFilter(EEG, filterfunction,offset)

disp(filterfunction)
eval(filterfunction)
EEG.data = EEG.data';
EEG.data = EEG.data(:,(offset*EEG.srate):end);
EEG.pnts = size(EEG.data,2);
EEG.icaact = [];
EEG = eeg_checkset(EEG);

pop_eegplot(EEG,0);
pop_selectcomps(EEG)
list_properties = component_properties(EEG,[234 244],[45 55]);
  rejection_options.measure=ones(1,size(list_properties,2));
    rejection_options.z=3*ones(1,size(list_properties,2));
    min_z(list_properties,rejection_options)
    
end