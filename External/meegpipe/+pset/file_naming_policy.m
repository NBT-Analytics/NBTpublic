function name = file_naming_policy(policy, filename)
% FILE_NAMING_POLICY - Decides the file name of a newly created pointset
%
% name = file_naming_policy(policy, filename)
%
%
% Where
%
% POLICY is the name of the policy. It can be either 'Inherit', 'Random' or
% 'Session'. See below for more details on these policies.
%
% FILENAME is the file name on which the generated name should be based.
% This argument is only relevant for some policies ('Inherit' and
% 'Session').
%
% NAME is the generated file name.
%
%
% ## Information on file naming policies:
%
% * The 'Inherit' policy requires a base file name (FILENAME) to be
%   provided. The output file name will have the same name as FILENAME but
%   but with a different file extension. See pset.globals.DataFileExt and
%   pset.globals.HdrFileExt for the default file extensions that will be
%   used.
%
% * The 'Random' policy will generate a random file name within the current
%   session folder. If no session is active, a new session will be
%   automatically created.
%
% * The 'Session' policy is a combination of 'Random' and 'Inherit'. The
%   path of the generated file name will be the session folder but its name
%   will be inherited from the provided base file name.
%
%
% See also: pset

import mperl.file.spec.*;
import pset.session;

FALLBACK_POLICY = 'random';

if ~ischar(policy),
    ME = MException('pset:file_naming_policy:InvalidType', ...
        'First input argument must be a char array');
    throw(ME);
end

if (nargin < 2 || isempty(filename)) && ...
        ismember(lower(policy), {'session', 'inherit'}),
    warning('pset:file_naming_policy:MissingBaseFileName', ...
        ['A base file name must be provided for policy ''%s''. ' ...
        'Falling back to ''%s'' policy'], policy, FALLBACK_POLICY);
    policy = FALLBACK_POLICY;
end

switch lower(policy),
    case 'inherit',        
        [path, name] = fileparts(filename);
        name = canonpath(rel2abs(catfile(path, name)));
    case 'random',
        name = canonpath(rel2abs(session.instance.tempname));
    case 'session',
        [~, name] = fileparts(filename);
        name = canonpath(rel2abs(catfile(session.instance.Folder, name)));
    otherwise
        ME = MException('pset:file_naming_policy:UnknownFileNamingPolicy', ...
            'Unknown file naming policy ''%s''', policy);
        throw(ME);
end



end