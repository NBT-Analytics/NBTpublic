function obj = saveobj(obj)
% SAVEOBJ Saves a pset object
%
% save(obj)
%
% Where
%
% OBJ is a pset object
%
%
% (c) German Gomez-Herrero
% Contact: german.gomezherrero@ieee.org
%
% See also: pset.

obj.Temporary = false;
destroy_mmemmapfile(obj);

end



