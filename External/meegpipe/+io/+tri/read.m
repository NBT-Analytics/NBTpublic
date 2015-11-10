function [vert, tri] = read(file)
% TRI_READ 
% Reads Freesurfer .tri surfaces
%
% [vert, tri] = read(filename)
%
% where
%
% FILENAME is the full path of the .tri file
%
% VERT is an Nx3 matrix with the Cartesian locations of the vertices
%
% TRI is an Mx3 matrix with triangle definitions. The ith triangle is
% found by connecting the coordinates VERT(TRI(i,1), :), VERT(TRI(i,2), :)
% and VERT(TRI(i,3), :)
%
%
% See also: io.tri


fid = fopen(file, 'r');
nVertices = textscan(fid, '%d', 1);
C = textscan(fid, '%f %f %f', nVertices{1}, 'CommentStyle', '#');
vert = cell2mat(C);
nTriangles = textscan(fid, '%d', 1);
C = textscan(fid, '%f %f %f', nTriangles{1}, 'CommentStyle', '#');
tri = cell2mat(C);
fclose(fid);


end