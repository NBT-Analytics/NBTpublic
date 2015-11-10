function [xyz, id] = read(file)
% IO.SFP.READ 
% Reads sensor coordinates from a BESA's surface point file
%
%
% [coord, label] = io.sfp.read(filename)
%
% 
% where
%
% FILENAME is the full path to the .sfp file
%
% COORD is a Nx3 matrix with the Cartesian coordinates of the sensors
%
% LABEL is a Nx1 cell array with sensor labels
%
%
% See also: io.sfp

fid = fopen(file, 'r');
C = textscan(fid, '%s %f %f %f', 'CommentStyle', '#');
fclose(fid);
xyz = cell2mat(C(2:end));
id = C{1};

end