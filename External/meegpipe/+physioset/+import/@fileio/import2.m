function physiosetObj = import(obj, varargin)
% IMPORT - Imports disk files using Fieldtrip fileio module
%
%   pObj = import(obj, fileName)
%   pObjArray = import(obj, fileName1, fileName2, ...);
%
% See also: physioset.import


import pset.globals;
import safefid.safefid;
import exceptions.*;
import misc.trigger2code;
import misc.decompress;
import pset.file_naming_policy;
import misc.sizeof;
import misc.eta;
import physioset.import.fileio;
import physioset.physioset;

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Deal with the multi-newFileName case
if nargin > 2
    physiosetObj = cell(numel(varargin), 1);
    for i = 1:numel(varargin)
        physiosetObj{i} = import(obj, varargin{i});
    end
    return;
end

fileName = varargin{1};
[fileName, obj] = resolve_link(obj, fileName);

% Default values of optional input arguments
verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

% Configuration options
eegRegexTrans   = obj.EegTransRegex;
megRegexTrans   = obj.MegTransRegex;
physRegexTrans  = obj.PhysTransRegex;

% The input file might be zipped
[status, fileName] = decompress(fileName, 'Verbose', verbose);
isZipped = ~status;



%%%%%



%% Convert trigger data to events
if verbose,
    fprintf([verboseLabel 'Reading events...']);
end
ftripEvs = ft_read_event(fileName);

events = [];
for i = 1:size(triggerData,1),
    [sample, code] = trigger2code(triggerData);
    for j = 1:numel(code),
        thisValue = code(j);
        if ~isempty(obj.Trigger2Type),
            thisType  = obj.Trigger2Type(code(j));
        else
            thisType = [];
        end
        if isempty(thisType),
            thisType = num2str(code(j));
        end
        thisEvent = physioset.event.event(sample(j), ...
            'Type', thisType, 'Value', thisValue);
        events = [events;thisEvent]; %#ok<AGROW>
    end
end
if verbose, fprintf('[done]\n\n'); end



%% Undoing stuff

% Unset the global verbose
goo.globals.set('VerboseLabel', origVerboseLabel);

% Delete unzipped data file
if isZipped,
    delete(fileName);
end


end