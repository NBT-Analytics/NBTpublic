function [dimens_diff,IndexbiomPerChans,IndexbiomNotPerChans] = nbt_dimension_check(B_values1,NCHANNELS)
for i= 1:size(B_values1,2)
    dimens(i) = length(B_values1{1,i});
end
% check index of biomarker computed for each channel
IndexbiomPerChans = find(dimens == NCHANNELS);
if(~isempty(dimens == 0)) %find empty biomarkers
    dimens = dimens(dimens ~=0);
end
dimens2 = sort(dimens);
if length(IndexbiomPerChans)==length(dimens)
    dimens_diff = 1;
    IndexbiomNotPerChans = [];
elseif length(dimens2)>1 & length(dimens2)~=length(IndexbiomPerChans)
    k = 0;
    l = 2;
    dim_num(1) = dimens2(1);
    for i = 1:length(dimens2)-1
        if dimens2(i) ~= dimens2(i+1)
            k = k+1;
            dim_num(l) = dimens2(i+1);
            l = l+1;
        end
    end
    dimens_diff = k; % number of biomarkers with different dimensionality (dimens_diff = all biomarkers have same dimensionality)
    dim_num(end+1) = dimens2(1); % Is this necessary?
    biomNotPerChans = find(unique(dim_num) ~= NCHANNELS);
    dim_num = dim_num(biomNotPerChans);
    % check index of biomarker not computed for each channel (i.e. questionnaire data)
    for i = 1:length(dimens)
        for j = 1:length(dim_num)
            IndexbiomNotPerChans{j} = find(dimens==dim_num(j));
        end
    end
     
elseif length(dimens2)==1
    if dimens2 == NCHANNELS
        IndexbiomPerChans = 1;
        dimens_diff = 1;
        IndexbiomNotPerChans = [];
    else
        IndexbiomPerChans = [];
        dimens_diff = 1;
        IndexbiomNotPerChans{1} = 1 ;
    end
    
    
end
% find how many biomarkers with different dimensionality

