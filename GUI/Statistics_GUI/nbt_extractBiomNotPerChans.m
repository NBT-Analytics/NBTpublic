function B_values1 = nbt_extractBiomNotPerChans(biomNotPerChans,B_values1_cell)
% extract only biomarker computed for each channel
for j = 1:size(B_values1_cell,1);
    for i = 1:length(biomNotPerChans)
        B_values1(:,j,i) = B_values1_cell{j,biomNotPerChans(i)};
    end
end