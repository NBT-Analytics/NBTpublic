function x = est09_LidCO(abp,onset,hr)
% EST09_LidCO  CO estimator 9: LidCO's root-mean-square method
%
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

n = length(hr);
x = zeros(n,1);
for i=1:length(hr)
    x(i) = std(abp(onset(i):onset(i+1))) * hr(i);
end
