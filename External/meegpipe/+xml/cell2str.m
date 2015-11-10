function y = cell2str(x, multiline, clip, brackets)
% CELL2STR Converts a cell array to a character array
%
%   Y = matrix2str(X) converts the cell array X={'a' 2 3; 4 5 '6'} into
%   the string '{'a' 2 3; 4 5 '6']}' so that X==eval(Y).
%
% See also: misc/struct2xml, misc/matrix2str

if nargin < 4 || isempty(brackets), brackets = true; end
if nargin < 3 || isempty(clip), clip = Inf; end
if nargin < 2 || isempty(multiline), multiline = false; end

if isempty(x),
    y = '{}';
    return;
end

if brackets,
    tmpStr = '{ ';
else
    tmpStr = '';
end
if ndims(x) > 2,
    error('Cell arrays of more than 2 dimensions are not supported');
end
for j = 1:size(x, 1),
    for k = 1:size(x, 2)
        this = mperl.char(x{j, k}, false);
        if ischar(x{j,k}),
            this = ['''' this ''''];
        end
        tmpStr = [tmpStr this];     %#ok<*AGROW>
        if k < size(x, 2),
            tmpStr = [tmpStr ' , '];
        end
    end
    if multiline && j < size(x, 1),
        tmpStr = [tmpStr sprintf(';\n ')];
    end
    if j < size(x, 1)
        tmpStr = [tmpStr ' ; '];
    end
end
if brackets,
    y = [tmpStr '}'];
else
    y = tmpStr;
end

if numel(y) > clip,
    idx = [strfind(y, ',') strfind(y, ';')];
    idx(idx > clip) = [];    
    if isempty(idx),
        y = [y(1:clip) ' ...]'];
    else
        y = [y(1:idx(end)) ' ...]'];
    end
end