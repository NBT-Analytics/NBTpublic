function featVals = co_features(data, r)


import cardiac_output.abpfeature;
import cardiac_output.wabp;

ABP_SRATE = 125;

if size(data,1) > 1,
    warning('co_features:SingleChannelExpected', ...
        'Ine ABP channel was expected, %d were found', size(data,1));
end

sr = data.SamplingRate;

% Resample to 125 Hz, what James Sun's cardiac_output functions expect
abp = data(1,:)';
abp = resample(abp, ABP_SRATE, sr);
r   = ceil(r*ABP_SRATE/sr);

out = abpfeature(abp, r);

% Select relevant columns and remove outliers
hr  = 60./(out(:, 7)./ABP_SRATE);
out = out(:, [2 4:6 8 10 12]);

hr2 = medfilt1(hr, 4);
hr(5:end) = hr2(5:end);

% HR and CO
out = [out hr (out(:,3)./(out(:,1)+out(:,2))).*hr];

featVals = trimmean(out, 1);

end