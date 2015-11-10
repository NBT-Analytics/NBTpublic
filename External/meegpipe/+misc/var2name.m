function varName = var2name(var)
% VAR2NAME - Provides an identifying name for a given variable
%
% varName = var2name(var)
%
% Where
%
% VAR is a MATLAB variable
%
% VARNAME is a string that can be used to identify (in most practical
% aspects, uniquely) such variable.
%
% See also: misc


import datahash.DataHash;
import misc.dimtype_str;

varName = regexprep(dimtype_str(var), '[^\w]+', '_');

% try to get a Hash of the var
warning('off', 'JSimon:DataHash:BadDataType');
hash = DataHash(var);
warning('on', 'JSimon:DataHash:BadDataType');
varName = [varName '_' hash(end-4:end)];


end
