function [Y] = merge_overlap(X1,X2,l)
% MERGE_OVERLAP - Merges two overlapping (possibly multidimensional) signals 
%
% Usage:
%   >>  Y = merge_overlap(X1,X2,L);
%
% Where:
%   X1    - First signal (dxN1)
%   X2    - Second signal to be merged to X1 (dxN2)
%   L     - Overlapping length (in samples)
%


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
Y = [int1 repmat(w1,d,1).*int2a+repmat(w2,d,1).*int2b int3];
