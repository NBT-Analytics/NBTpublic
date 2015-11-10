function obj = smooth_transitions(obj, ev, varargin)

% Documentation: class_pset_pset.txt
% Description: Smooths out transitions between epochs

import misc.epoch_get;
import misc.epoch_set;

for evItr = 1:numel(ev)
    
    thisEv = ev(evItr);
    
    thisEpoch = epoch_get(obj, thisEv);
    
    if isempty(thisEpoch), continue; end
    
    thisEpoch = merge_overlap(thisEpoch); 
    
    obj = epoch_set(obj, thisEv, thisEpoch);  
    
end


end

function Y = merge_overlap(X)

wl = (size(X,2)-1)/2;
X1 = X(:,1:wl);
X2 = X(:, wl+1:end);
l = ceil(.75*wl);

[d,l1] = size(X1);

n1=l;
n2=l;

wl = l;
w1 = linspace(1,0,wl);
w2 = linspace(0,1,wl);
int1 = X1(:,1:l1-n1);
int2a = X1(:,l1-n1+1:end);
int2b = X2(:,1:n2);
int3 = X2(:,n2+1:end);

newChunk = repmat(w1,d,1).*int2a+repmat(w2,d,1).*int2b;
newChunk2 = nan(d, 2*l);
for i = 1:d
    newChunk2(i,:) = interp1(1:2:2*l+1, [newChunk(i,:) int3(i,1)], 1:2*l);
end


Y = [int1 newChunk2 int3];


end