function obj = initialize(obj)
% INITIALIZE - Prepares report for generation
%
% obj = initialize(obj, data)
%
%
% See also: generate, finalize, abstract_generator

import safefid.safefid;
import mperl.file.spec.catfile;

% Initialize rootpath
set_rootpath(obj, def_rootpath(obj));


% Initialize file handle
if isempty(get_fid(obj)) && isempty(get_filename(obj)),
    % Use a default report file name
    
    defFileName = def_filename(obj);    
    set_filename(obj, defFileName);    
       
    if ~exist(get_rootpath(obj), 'dir'),
        mkdir(get_rootpath(obj));
    end    
    
    defFileName = catfile(get_rootpath(obj), get_filename(obj));
    %defFileName = get_filename(obj);
    set_fid(obj, safefid.fopen(defFileName, 'w'));
  
elseif ~isempty(get_fid(obj)),    
    % Attach filename to FID
    
    set_filename(obj, safefid.fopen(get_fid(obj)));
    
else
    % Attach a FID to filename
    file = catfile(get_rootpath(obj), get_filename(obj));
    set_fid(obj, safefid.fopen(file, 'w'));
    
end

% Print title and parent
print_title(obj);
print_parent(obj);


end