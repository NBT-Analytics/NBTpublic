function [bndry, index] = chop(obj, data, varargin)


%% Preliminaries
import misc.delay_embed;
import misc.eta;
import misc.peakdet;
import goo.globals;
import spt.pca;

% How many tries at finding peaks in the chopping index
MAX_TRIES = 20;

if size(data, 1) < 2 && obj.EmbedDim < 2,
    
    warning('ged:OnlyOneDim', ...
        ['The GED chopper requires at least 2-dim data: ' ...
        'data will be delay-embedded with EmbedDim=5']);
    obj.EmbedDim = 5;    
    
end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerboseLabel = globals.get('VerboseLabel');
globals.set('VerboseLabel', verboseLabel);

% quick fix for now. Maybe add a PCA property later on?
if size(data,1) > 10,
    
    nRows = 0;
    while nRows < 5,
        pcaObj = learn(pca('Var', .95), data);
        pcs = proj(pcaObj, data);
        nRows = size(pcs,1);
    end
    data = pcs;
end

%% Parse object properties
if isempty(obj.WindowLength),
    obj.WindowLength = ...
        @(data) max(1, min(size(data,1)^2*100, floor(size(data,2)/100)));    
end

if isa(obj.WindowLength, 'function_handle'),
    wl = obj.WindowLength(data);
else
    wl = obj.WindowLength;
end

if isempty(obj.WindowOverlap),
    ws = wl;
else
    ws = max(1, wl-ceil(obj.WindowOverlap*wl/100)); 
end

% Ensure that ws is small enough
ws = min(ws, ceil((size(data,2)-2*wl)/100));

if isempty(obj.NbEig),
    nbEig = size(data,1)*obj.EmbedDim;
else
    nbEig = obj.NbEig;
end

if isempty(obj.MinChunkLength),
    obj.MinChunkLength = @(data) 50*size(data,1)^2;
end

if isa(obj.MinChunkLength, 'function_handle'),
    
    obj.MinChunkLength = obj.MinChunkLength(data);
    
end

if isempty(obj.MaxNbChunks),
    obj.MaxNbChunks = max(1, floor(size(data,2)/obj.MinChunkLength));
end

if obj.MaxNbChunks < 2,
    warning('chopper:ged:chop:OnlyOneChunkAllowed', ...
        'MaxNbChunks < 2 and therefore no chunks have been extracted');
    index = ones(1, size(data,2));
    bndry = false(1, size(data,2));
    return;
end

if isa(data, 'pset.mmappset'),
    data = copy(data);
end

%% Pre-processing filter
if ~isempty(obj.PreFilter),
    if verbose,
        if isa(data, 'pset.mmappset'),
            fprintf([verboseLabel 'Filtering %s...'], get_name(data));
        else
            fprintf([verboseLabel 'Filtering ...']);
        end
    end
    data = filtfilt(obj.PreFilter, data);
    if verbose,
        fprintf('\n\n');
    end
end

X       = delay_embed(data(:,:), obj.EmbedDim, obj.EmbedDelay);
init    = wl:ws:(size(data,2)-wl);
ne      = numel(init);

if ne < 10,
   warning('ged:TooShortTS', ...
       'Time series are too short: no chopping was performed');
   bndry = false(1, size(data,2));
   index = [];
   return;
end

%% Compute the chopping index
if verbose,
    fprintf([verboseLabel 'Chopping...']);
end
tinit = tic;
index = zeros(1, size(data,2));
for i = 1:ne
    
    X1 = X(:, max(1, init(i)-wl+1):init(i));
    X2 = X(:, min(size(data,2), init(i):init(i)+wl-1));    
    C1 = cov(X1');
    C2 = cov(X2');
    E = eig(C1, C2);
   
    index(init(i)) = E(nbEig)./E(1);
    
    if verbose,
        eta(tinit, ne, i);
    end
    
end

index = interp1(init, index(init), 1:size(data,2));
index(1:init(1)) = index(init(1));
index(init(end)+1:end) = index(init(end));
if any(isnan(index)),
    index(isnan(index)) = mean(index(~isnan(index)));
end

if ~isempty(obj.PostFilter),
    index = filtfilt(obj.PostFilter, index);
end
if verbose,
    fprintf('\n\n');
end

%% Detect peaks in the index
if verbose,
    fprintf([verboseLabel 'Merging too small chunks...']);
end
delta = obj.InitDelta;
maxtab = peakdet(index, delta);

tries = 0;
if isempty(maxtab),
    while (size(maxtab,1) < 1) && tries < MAX_TRIES
        delta = .9*delta;
        maxtab = peakdet(index, delta);
        tries = tries + 1;
    end
else    
    while (size(maxtab,1) > obj.MaxNbChunks) && tries < MAX_TRIES
        delta = 1.1*delta;
        maxtab = peakdet(index, delta);
        tries = tries + 1;
    end
end

if isempty(maxtab),
    bndry = false(1, size(data,2));
    bndry([1 size(data,2)]) = true;    
    return;
end

%% Remove peaks that are too close to each other
peakDistance = diff(maxtab(:,1));
alreadyUsed  = false(size(maxtab,1),1);
while(~isempty(peakDistance) && ...
        any(peakDistance < obj.MinChunkLength) && ~isempty(maxtab) && ...
        ~all(alreadyUsed)) 
    
    % The largest unused peak
    [~, thisPeakIdx]    = max(maxtab(~alreadyUsed,2));
    unusedIdx           = find(~alreadyUsed);
    thisPeakIdx         = unusedIdx(thisPeakIdx);
    
    % Remove too near peaks    
    thisDistance = abs(maxtab(thisPeakIdx,1)-maxtab(:,1));
    isNear = find(thisDistance > 0 & thisDistance < obj.MinChunkLength);
    alreadyUsed(thisPeakIdx)= true;
    maxtab(isNear,:)        = [];
    alreadyUsed(isNear,:)   = [];
    peakDistance            = diff(maxtab(:,1));
    
end

maxtab(maxtab(:,1)<obj.MinChunkLength,:)                = [];
maxtab(size(data,2)-maxtab(:,1) < obj.MinChunkLength,:)    = [];

bndry = false(1, size(data,2));
bndry(maxtab(:,1)) = true; 
bndry(1) = true;
bndry(end) = true;

%% Print summary of results
if verbose,
    idx = find(bndry);
    nbChunks = numel(idx)-1;
    avgLength = mean(diff(idx));
    fprintf(...
        '[%d chunks, avg=%d samples, min=%d samples, max=%d samples]\n\n', ...
        nbChunks, round(avgLength), min(diff(idx)), max(diff(idx)));
end

%% Final touches
globals.set('VerboseLabel', origVerboseLabel);

end

