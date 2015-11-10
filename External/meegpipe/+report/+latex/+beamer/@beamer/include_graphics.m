function include_graphics(obj, h, caption, varargin)
% INCLUDE_GRAPHICS - Include figure in Latex-beamer slides
%
% include_graphics(obj, h, caption)
% include_graphics(obj, h, caption, 'key', value, ...)
%
% Where
%
% H is a figure handle or a cell array of figure handles.
%
% CAPTION is a caption string or a cell array of caption strings (whose
% dimensions must match those of the cell array H).
%
% ## Accepted (optional) key/value pairs:
%
% Width     : A string. Default: 0.85\textwidth
%
% Height    : A string. Default: ''
%
%
% See also: beamer

% Documentation: class_beamer.txt
% Description: Include figure in Latex-beamer slides

import plot2svg.plot2svg;
import inkscape.svg2pdf;
import mperl.file.spec.*;
import misc.process_arguments;

if nargin < 3 || isempty(caption),
    caption = '';
end

if isempty(obj.FID),
    error('Uninitialized beamer object');
end

opt.Width = '.9\textwidth';
opt.Height = '';
[~, opt] = process_arguments(opt, varargin);

if ~iscell(h),
    h = {h};
end

if ~iscell(caption) && ~isempty(caption),
    caption = {caption};
elseif isempty(caption),
    caption = repmat({''}, 1, numel(h));
end

for i = 1:numel(h),
    
    figName = regexprep(caption{i}, '[_\s]+', '-');
    fName = catfile(obj.RootDir, figName);
    plot2svg([fName '.svg'], h{i});        
    svg2pdf([fName '.svg'], [fName '-latex.pdf'], true);
    
    fprintf(obj.FID, '\\begin{figure}\n\\tiny');
    
    if ~isempty(opt.Width),
       fprintf(obj.FID, '\\def\\svgwidth{%s}\n', opt.Width);
    end
    
    if ~isempty(opt.Height),
        fprintf(obj.FID, '\\def\\svgheight{%s}\n', opt.Height);
    end
    
    texFName = [figName  '-latex.pdf_tex'];
    texFullFName = catfile(obj.RootDir, texFName);
    texFName = strrep(texFName, '_', '-');
    texFName = strrep(texFName, '\', '/');
    movefile(texFullFName, catfile(obj.RootDir, texFName));    
    
    
    fprintf(obj.FID,'\\begin{center}\n\\input{./%s}\n\n', texFName);
    
    % No captions for now...
%     if ~isempty(caption{i}),
%         fprintf(obj.FID, '\\caption{%s}\n', caption{i});
%     end
    
    fprintf(obj.FID, '\\end{center}\n\\end{figure}\n\n');       
    
    
end

end