function newObj = subset(obj, varargin)
% subset - Create physioset as a subset of another physioset
%
% See: <a href="matlab:misc.md_help('+physioset/@physioset/subset.md')">misc.md_help(''+physioset/@physioset/subset.md'')</a>
%
%
% See also: physioset


import physioset.physioset;
import physioset.event.std.discontinuity;
import misc.isnatural;

if nargin > 1 && isa(varargin{1}, 'pset.selector.selector'),
    
    select(varargin{1}, obj);
    dimSel = obj.DimSelection;
    pntSel = obj.PntSelection;
    restore_selection(obj);
    varargin = varargin(2:end);
    
elseif nargin > 2 && isnatural(varargin{2}),
    
    dimSel = varargin{1};
    pntSel = varargin{2};
    varargin = varargin(3:end);
    
elseif nargin > 1 && isnatural(varargin{1}),
    
    dimSel = varargin{1};
    pntSel = 1:nb_pnt(obj);
    varargin = varargin(2:end);
    
else
    
    dimSel = 1:nb_dim(obj);
    pntSel = 1:nb_pnt(obj);
   
end

% Make a temporary selection
select(obj, dimSel, pntSel);
samplingTime = sampling_time(obj);
badSample    = is_bad_sample(obj, 1:nb_pnt(obj));
event        = get_event(obj);
badChan      = is_bad_channel(obj, 1:nb_dim(obj));
sensObj      = sensors(obj);

[eqWeights, eqWeightsOrig, physDimPrefixOrig] = get_equalization(obj);

% undo the selection
restore_selection(obj);

% Create a low-level pointset
psetObj = subset(obj.PointSet, dimSel, pntSel, varargin{:});

args = construction_args(obj);

newObj = physioset.from_pset(psetObj, args{:}, ...
    'Sensors',              sensObj, ...
    'Event',                event, ...
    'SamplingTime',         samplingTime, ...
    'EqWeights',            eqWeights, ...
    'EqWeightsOrig',        eqWeightsOrig, ...
    'PhysDimPrefixOrig',    physDimPrefixOrig, ...
    'BadChannel',           badChan, ...
    'BadSample',            badSample);

newObj.SensorsHistory    = obj.SensorsHistory;

% Add discontinuity events at the discontinuities
discPos = find(diff(pntSel) > 1);
if ~isempty(discPos),
    add_event(newObj, discontinuity(discPos));
end

end