function objOut = eeg_bands(varargin)

bois = { 'delta', 'alpha', 'theta', 'beta', 'gamma' };

if nargin > 0,
    bois = intersect(bois, lower(varargin));
end
   
% band = {[targetBand1;targetBand2], [baseBand1;baseBand2]}
obj = mjava.hash;
obj('delta') = {[0 4], [0 100]};
obj('alpha') = {[8 13], [0 100]};
obj('theta') = {[4 8],  [0 100]};
obj('beta')  = {[13 30], [0 100]};
obj('gamma') = {[30 100], [0 100]};

objOut = mjava.hash;
for i = 1:numel(bois)
    objOut(bois{i}) = obj(bois{i});
end




end