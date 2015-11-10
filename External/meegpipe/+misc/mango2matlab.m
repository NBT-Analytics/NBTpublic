function data = mango2matlab(file)
% mango2matlab - Imports Mango's .csv file with point-ROIs coordinates
%
% xyz = mango2matlab(file)
%
% Where
%
% FILE is a .csv file exported from Mango and that contains the coordinates
% of a set of point ROIs
% 
% XYZ is an Nx3 array with the coordinates of the point ROIs
%
%
% #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
% # The EEGC package for MATLAB                                           #
% # German Gomez-Herrero <german.gomezherrero@ieee.org>                   #
% # Netherlands Institute for Neuroscience                                #
% # Amsterdam, The Netherlands                                            #
% #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
%
% See also: EEGC

tempfile = tempname;
perl('+EEGC/mango2matlab.pl', file, tempfile);
data = dlmread(tempfile);
delete(tempfile);

