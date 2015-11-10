function md_help(varargin)
% md_help - Display associated Markdown help file
%
% md_help works in the same way as MATLAB's built-in help() function, but
% instead of reading the .m file documentation from the first block of comments
% within the .m file, it reads them from an associated .md file with the same
% name. In the case of package names, md_help displays the contents of the
% README.md file at the package root folder. Then it displays also the output
% produced by MATLAB's built-in help() when called on package names.
%
% See also: misc

import misc.get_package_list;
import mperl.file.spec.catfile;

if nargin > 1,
    for i = 1:nargin
        fprintf('\n\n---- md_help for %s\n\n', varargin{i});
        md_help(varargin{i});
    end
    return;
end

file = which(varargin{1});

if isempty(file),
    % might be a package
    [pkgList, dirList] = get_package_list;
    [found, loc] = ismember(varargin{1}, pkgList);
    
    if ~found,
        [found, loc] = ismember(strrep(varargin{1}, filesep, '/'), dirList);
    end
    
    if found,
        pkgDir = dirList{loc};
        readme = [pkgDir '/README.md'];
        if exist(readme, 'file'),
            parse(readme);
        end
    end
    help(varargin{1});
else
    % It's a regular .m file
    [pathName, fileName] = fileparts(file);
    mdFile = catfile(pathName, [fileName '.md']);
    if exist(mdFile, 'file'),
        parse(mdFile);
    elseif ~isempty(regexp(file, '@([^/\\]+)(/|\\)', 'once'))
        % It's a class name, maybe there is a README.md
        mdFile = [pathName filesep 'README.md'];
        if exist(mdFile, 'file'),
            parse(mdFile);
        end      
    else
        help(varargin{1});
    end
end


end


function parse(fname)

import safefid.safefid;
import mperl.file.spec.catfile;

NB_BLANKS_3 = 0;
NB_BLANKS_2 = 1;

rPath = fileparts(fname);

fid = safefid(fname);
fprintf('\n\n');
codeBlock = false;
nbBlankLines = 0;

while 1
    tline = fid.fgetl;
    if ~ischar(tline), break, end
    
    if ~isempty(regexp(tline, '^\s+$', 'once')),
        nbBlankLines = nbBlankLines + 1;
        if ~codeBlock && nbBlankLines < 3,
            fprintf('\n');
        elseif codeBlock && nbBlankLines < 2,
            fprintf('\n');
        else
            continue;
        end 
    end
           
    
    % Start a code block
    if ~isempty(regexp(tline, '^````matlab', 'once')),
        codeBlock = true;
        nbBlankLines = 0;
        continue;
    end
    
    % End of code block
    if codeBlock && ~isempty(regexp(tline, '^````', 'once')),
        codeBlock = false;
        nbBlankLines = 0;
        continue;
    end
    
    if codeBlock,
        fprintf('%s\n', ['  ' tline]);
        nbBlankLines = 0;
        continue;
    end
    
    % Parse titles
    [found, ~, ~, ~, tokens] = regexp(tline, '^##\s*([^#]+)', 'once');
    if ~isempty(found)
        tokens = tokens{1};
        % Always 4 spaces between this level of titles
        if nbBlankLines < NB_BLANKS_2,
            fprintf(repmat('\n', 1, NB_BLANKS_2-nbBlankLines));
        end
        out = ['<strong>' upper(tokens) '</strong>'];
        fprintf('%s\n', out);
        fprintf([repmat('=', 1, numel(tokens)+5) '\n\n']);
        nbBlankLines = 0;
        continue;
    end
    [found, ~, ~, ~, tokens] = regexp(tline, '^###\s*([^#]+)', 'once');
    if ~isempty(found),
        tokens = tokens{1};
        % Always 2 spaces between this level of titles
        if nbBlankLines < NB_BLANKS_3,
            fprintf(repmat('\n', 1, NB_BLANKS_3-nbBlankLines));     
        end
        fprintf('%s\n', ['<strong>' tokens '</strong>']);
        fprintf([repmat('.', 1, numel(tokens)+5) '\n\n']);
        nbBlankLines = 0;
        continue;
    end
    
    % Parse hyperlinks
    [found, ~, ~, ~, tokens] = regexp(tline, ...
        '^\s*\[([^\]]+)\]:\s*(.+)\s*$');
    
    if found,
        tokens = tokens{1};
        name   = tokens{1};
        if strcmp(tokens{2}(1), '.'),
            % It's a relative path
            url = ['matlab: misc.md_help(''' catfile(rPath, tokens{2}) ''')'];
        else
            url  = ['matlab:web(''' tokens{2} ''', ''-browser'')'];
        end
        tline = ['<a href= "' url '">'  name '</a>'];
        fprintf('%s\n', tline);
        nbBlankLines = 0;
        continue;
    end
    
    % Parse `` and __ __
    tline = regexprep(tline, '__([^_]+)__', '<strong>$1</strong>');
    %tline = regexprep(tline, '`([^`]+)`', '|$1|');
    
    fprintf('%s\n', tline);
    nbBlankLines = 0;
      
end

fprintf('\n');

end
