function obj = add_figure(obj, fileName, caption, thumb, link)

import misc.is_string;
import report.gallery.gallery;
import mperl.file.spec.rel2abs;

%% Check input args
if nargin < 2 || isempty(fileName),
    return;
end

if ~iscell(fileName) && ~ischar(fileName),
    throw(gallery.InvalidArgValue('fileName', ...
        'Must a string or a cell array of strings'));
end

if nargin < 4 || isempty(thumb), thumb = true; end
if nargin < 5 || isempty(link), link = true; end

if nargin < 3 || isempty(caption),
    if iscell(fileName),
        caption = repmat({''}, size(fileName,1), size(fileName,2));
    else
        caption = '';
    end
end

if iscell(fileName) && ~iscell(caption),
    error('Argument CAPTION must be a cell array of strings');
elseif ischar(caption) && ~ischar(caption),
    error('Argument CAPTION must be a string');
end

if ~islogical(thumb) || ~islogical(link),
    error('Arguments THUMB and LINK must be logical arrays');
end

if iscell(fileName) && numel(fileName) > 1,
   if numel(thumb) == 1,
       thumb = repmat(thumb, 1, numel(fileName));
   end
   if numel(link) == 1,
       link = repmat(link, 1, numel(fileName));
   end
   if numel(thumb) ~= numel(fileName),
       error('Dimensions of THUMB do not match dimensions of FILENAME');
   end
   if numel(link) ~= numel(fileName),
       error('Dimensions of LINK do not match dimensions of FILENAME');
   end
end


%% Deal with the case of multiple figures provided in once call
if iscell(fileName),
    for i = 1:numel(fileName)
       obj = add_figure(obj, fileName{i}, caption{i}, thumb(i), link(i)); 
    end
    return;
end

if ~is_string(fileName),
    error('Argument FILENAME must be a string');
end
if ~is_string(caption),
    error('Argument CAPTION must be a string');
end

if ~isempty(fileparts(fileName)),
    [~, name, ext] = fileparts(fileName);
    fileName = [name ext];
end

if ismember(fileName, obj.Files),
    warning('gallery:AlreadyInGallery', ...
        'File is already in gallery: nothing was done');
    return;
end

obj.Files       = [obj.Files;{fileName}];
obj.Captions    = [obj.Captions;{caption}];

if link,
    obj.Link = [obj.Link; {fileName}];
end
if thumb, 
    obj.ThumbNail = [obj.ThumbNail; {fileName}];
end



end