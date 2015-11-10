function y = merge(varargin)
% merge - Merge two or more physioset objects
%
% See: <a href="matlab:misc.md_help('+physioset/@physioset/fieldtrip.md')">misc.md_help(''+physioset/@physioset/fieldtrip.md'')</a>
%
%
% See also: physioset

%% Preliminaries
import misc.process_arguments;
import physioset.physioset;
import mperl.file.spec.catfile;
import pset.session;
import pset.globals;
import physioset.event.std.file_begin;
import misc.eta;

obj = varargin{1};

count = 1;

while count <= nargin && isa(varargin{count}, 'physioset.physioset')
    count = count +1;
end
thisArgs = varargin(count:end);
varargin = varargin(1:count-1);

dataExt             = globals.get.DataFileExt;

verbose             = is_verbose(obj);
verboseLabel        = get_verbose_label(obj);

%% Optional input arguments
opt.path            = [];
opt.datafile        = [];
opt.prefix          = [];
opt.postfix         = [];
opt.overwrite       = true;
opt.temporary       = [];
opt.writable        = [];
opt.precision       = [];
opt.transposed      = [];

[~, opt] = process_arguments(opt, thisArgs);

if isempty(opt.datafile) && isempty(opt.prefix) && isempty(opt.postfix),
    opt.datafile = [...
        session.instance.tempname ...
        globals.get.DataFileExt ...
        ];
end

[path, name] = fileparts(obj.PointSet.DataFile);

if ~isempty(opt.datafile),
    [path, name] = fileparts(opt.datafile);
end

if ~isempty(opt.path),
    path = opt.path;
end

opt.datafile = catfile(path, [opt.prefix name opt.postfix dataExt]);

if ~opt.overwrite && exist(opt.datafile, 'file'),
    warning('physioset:merge:FileExists', ...
        'File %s already exists. Nothing done!', opt.datafile);     
end

%% Concatenate them in time and write the result to a new file
eqWeights       = obj.EqWeights;
eqWeightsOrig   = obj.EqWeightsOrig;

psets   = cell(numel(varargin),1);
sr      = obj.SamplingRate;
count   = 0;

events = [];
tinit = tic;
if verbose,
    fprintf(...
        [verboseLabel 'Merging events from %d physiosets ...'], ...
        numel(varargin));
end

for i = 1:numel(varargin)
    if varargin{i}.SamplingRate ~= sr,
        error('Cannot concatenate datasets with different sampling rates')
    end
    psets{i} = varargin{i}.PointSet;
    
    % Fix the timings of the events    
    newEvents = shift(get_event(varargin{i}), count); 
    
    % Add an event that makes clear where this data came from
    [~, name, ext] = fileparts(get_datafile(varargin{i}));
    fileEvent = file_begin(count+1, ...
        'Duration', varargin{i}.NbPoints, ...
        'Value',    [name ext]);
    
    events = [events;newEvents(:);fileEvent];       %#ok<*AGROW>
    
    count = count + varargin{i}.NbPoints;
    
    if verbose,
       eta(tinit, numel(varargin), i); 
    end
end
if verbose,
    fprintf('\n\n');
    clear +misc/eta;
end

% Fix the equalizations
if verbose && ~isempty(eqWeightsOrig),
    fprintf(...
        [verboseLabel 'Merging equalizations from %d physiosets ...'], ...
        numel(varargin));
end
tinit = tic;
for i = 2:numel(psets),
    if ~isempty(varargin{i}.EqWeightsOrig),
        psets{i} = eqWeightsOrig*pinv(varargin{i}.EqWeightsOrig)*psets{i};
    end
    if verbose && ~isempty(eqWeightsOrig),
       eta(tinit, numel(varargin), i); 
    end
end
if verbose && ~isempty(eqWeightsOrig),
    fprintf('\n\n');
    clear +misc/eta;
end

concatenatedPset = concatenate(psets{:}, 'FileName', opt.datafile);
concatenatedPset.Temporary = false;

newFileName = get_datafile(concatenatedPset);
clear concatenatedPset; % to destroy the memory map but not the file


%% Create an physioset object associated to the new memory-mapped file
if isempty(opt.temporary),
    opt.temporary = obj.PointSet.Temporary;
end
if isempty(opt.writable),
    opt.writable = obj.PointSet.Writable;
end
if isempty(opt.precision),
    opt.precision = obj.PointSet.Precision;
end    
if isempty(opt.transposed),
    opt.transposed = obj.PointSet.Transposed;
end

y = physioset(newFileName, obj.PointSet.NbDims, ...  
    'EqWeights',        eqWeights, ...
    'EqWeightsOrig',    eqWeightsOrig, ...
    'SamplingRate',     obj.SamplingRate, ...
    'Sensors',          obj.Sensors, ...
    'Event',            events, ...
    'StartDate',        obj.StartDate, ...
    'StartTime',        obj.StartTime, ...
    'Precision',        opt.precision, ...
    'Temporary',        opt.temporary, ...
    'Transposed',       opt.transposed, ...
    'Writable',         opt.writable);

%% Bad channels and bad samples for the merged dataset
badChan = obj.BadChan(:);
badSample = obj.BadSample(:);
for i = 2:numel(varargin)
   
    badChan = badChan | varargin{i}.BadChan(:);
    badSample = [badSample; varargin{i}.BadSample(:)]; %#ok<AGROW>
    
end

%% Manually copy private properties
y.EqWeights         = obj.EqWeights;
y.EqWeightsOrig     = obj.EqWeightsOrig;
y.PhysDimPrefixOrig = obj.PhysDimPrefixOrig;
y.BadChan           = badChan;
y.BadSample         = badSample;
y.ProcHistory       = obj.ProcHistory;

set_name(y, get_full_name(obj));

if ~isempty(obj.PntSelection) || ~isempty(obj.DimSelection),
    select(y, obj.DimSelection, obj.PntSelection);
end

%% Copy meta-properties
set_meta(y, get_meta(obj));


end
