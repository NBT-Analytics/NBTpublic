function n_points = get_nb_points(fid, n_dims, precision)
% get_nb_points - Returns the number of points stored in a binary file
%

import pset.globals; 
import pset.pset;
import misc.sizeof;

if nargin < 3 || isempty(precision) || isempty(n_dims) || isempty(fid), 
    ME = MException('get_nb_points:invalidInput', ...
        'Not enough input arguments');
    throw(ME);
end

n_bytes = sizeof(precision)*n_dims;

fseek(fid,0,'eof');
pos = ftell(fid);
n_points = floor(pos/n_bytes);
fseek(fid,0,'bof');
if (ceil(pos/(n_bytes*n_dims)) - n_points) > eps,
    ME = MExceptoin('get_nb_points:inconsistentNbPoints',...
        'There is an inconsistent number of points in this file.');
    throw(ME);
end

    

end