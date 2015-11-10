function [y] = minor(X,i,j)
% Computes a matrix minor by removing ith row and jth column

% version 1.0 gomezherrero 301106

% (c) German Gomez-Herrero, german.gomezherrero@tut.fi
% Institute of Signal Processing, Tampere University of Technology, Finland

X(i,:)= [];
X(:,j)= [];
y = det(X);
