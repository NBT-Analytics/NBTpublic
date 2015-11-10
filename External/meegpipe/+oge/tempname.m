function fname = tempname(root, ext)
% TEMPNAME - Temporary file name
%
% fname = tempname(root, ext)
%
% Where
%
% ROOT is a directory name
%
% EXT is the extension of the generated file
%
% TEMPNAME is a unique temporary file name located in directory ROOT and
% having extension EXT
%
% See also: oge

import mperl.file.spec.catfile;

MAX_ITER = 100;

if nargin < 2 || isempty(ext), ext = ''; end
if nargin < 1 || isempty(root), root = fileparts(tempname); end

if ~isempty(ext) && ~strcmp(ext(1), '.'),
    ext = ['.' ext];
end

if ~exist(root, 'dir'),
    mkdir(root);
end

[~, name] = fileparts(tempname);
fname = catfile(root, [name ext]);
count = 0;
while (exist(fname, 'file'))
    [~, name] = fileparts(tempname);
    fname = catfile(root, [name ext]);
    count = count + 1;
    if count > MAX_ITER,
        error('I could not generate a valid temporary file name');
    end
end




end