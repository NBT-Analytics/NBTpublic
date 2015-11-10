function y = cart2eeglab(x)
% CART2EEGLAB - Conversion from Cartesian coordinates to EEGLAB struct
%
%
% See also: sensors.eeg

import misc.check_dependency;

if isempty(x), y = []; return; end

check_dependency('eeglab');

tmpfilename = [tempname '.xyz'];

% Note: Despite what reads from the help of readlocs(), the cartesian
% coordinates that are stored in EGI's .mff files are identical to the 
% cartesian coordinates used by EEGLAB. So we don't need any conversion
% here. This might not be true for other EGI file formats but in such cases
% the conversion should be done during the import and NEVER here!
dlmwrite(tmpfilename,[(1:size(x,1))' x(:,1) x(:,2) x(:,3) (1:size(x,1))'],' ');

y = readlocs(tmpfilename, 'filetype', 'xyz');
y = y(:);

delete(tmpfilename);