function count = fprintf(fid, varargin)
% FPRINTF - Print gallery object to open file handle
%
% count = fprintf(fid, obj)
%
% Where
%
% OBJ is a gallery object and FID is an open file handle.
%
% COUNT is the number o characters successfully printed.
%
% See also: gallery

import report.gallery.gallery;

count = 0; 
%% Deal with multiple galleries
if nargin > 2,
   
    for i = 1:numel(varargin),
        
        fprintf(fid, varargin{i});
        
    end
    
    return;
    
end

%% Print just one gallery
obj = varargin{1};

if nb_figures(obj) < 1, return; end

level = get_level(obj);

%% Title and gallery settings
galName = get_title(obj);

if ~isempty(galName)
        count = count + ...
            fprintf(fid, '%s %s\n\n', repmat('#', 1, level + 1), galName);
end

level = level + 2;

count = count + ...
    fprintf(fid, '[[set_many Gallery]]:\n');
count = count + ...
    fprintf(fid, '\t thumbnail_max_width %d\n',    get_config(obj, 'ThumbWidth'));
count = count + ...
    fprintf(fid, '\t thumbnail_max_height %d\n\n', get_config(obj, 'ThumbHeight'));
count = count + ...
    fprintf(fid, '[[Gallery]]:\n\n');

%% Thumbnails
noThumbs = get_config(obj, 'NoThumbs');

if ~noThumbs && ~isempty(obj.ThumbNail)
    
    for figItr = 1:nb_figures(obj)
        
        fileName = get_filename(obj, figItr);
        if ~ismember(fileName, obj.ThumbNail) || ...
                isempty(regexp(fileName, get_config(obj, 'ThumbsRegex'), 'once')),
            continue;
        end            
        
        [~, thisFilename ext] = fileparts(fileName);
        count = count + ...
            fprintf(fid, '\t%s\n', [thisFilename ext]);
        caption = get_caption(obj, figItr);
        if ~isempty(caption),
            fprintf(fid, '\t- %s\n\t\n', caption);
        end
        
    end
    
end

%% Links
NoLinks = get(obj, 'NoLinks');

level = level + 1;

if ~NoLinks && ~isempty(obj.Link)
        
    count = count + ...
        fprintf(fid, '%s %s\n\n', repmat('#', 1, level), 'Image links');
    
    for figItr = 1:nb_figures(obj)
        
        fileName = get_filename(obj, figItr);
        
         if ~ismember(fileName, obj.Link) || ...
                isempty(regexp(fileName, get(obj, 'LinksRegex'), 'once')),
            continue;
        end           
        
        ref      = get_ref(obj,     figItr);
        caption  = get_caption(obj, figItr);
        
        count = count + ...
            fprintf(fid, '[%s][%s]\n\n', caption, ref);
        
    end
    
    count = count + fprintf(fid, '\n\n');
    
    for figItr = 1:nb_figures(obj)
        
        fileName = get_filename(obj, figItr);
        
        if ~ismember(fileName, obj.Link) || ...
                isempty(regexp(fileName, get(obj, 'LinksRegex'), 'once')),
            continue;
        end
        
        ref     = get_ref(obj, figItr);
        count = count + ...
            fprintf(fid, '[%s]: %s\n', ref, fileName);
        
    end
end

count = count + fprintf(fid, '\n\n');


end