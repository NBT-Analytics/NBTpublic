function info = get_surface_files(surfacesPath, nbVertices)

import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;

if nargin < 2, nbVertices = []; end

files = misc.dir(surfacesPath, [], true, false, false);

info = struct( ...
    'id',               [], ...
    'outerskin',        [], ...
    'outerskull',       [], ...
    'innerskull',       [], ...
    'outerskindense',   [], ...
    'outerskulldense',  [], ...
    'innerskulldense',  [], ...
    'density',          nbVertices);

for i = 1:numel(files)   
    
    patDense   = '^\d+-[^-]+-dense.tri$';
    patSparse  = '^\d+-[^-]+-\d+.tri$';
    
    if ~isempty(regexpi(files{i}, patSparse)),
        % Sparse surface files
        pat = '^(?<id>\d+)-(?<surface>[^-]+)-(?<density>\d+).tri$';
        names = regexpi(files{i}, pat, 'names');
        if ~isempty(info.id),
            if ~strcmpi(names.id, info.id),
                error('id does not match across surface files');
            end
        else
            info.id = names.id;
        end
        if ~isempty(info.density),
            if str2double(names.density) ~= info.density,
                throw(AmbiguousDensity);
            end
        else
            info.density = str2double(names.density);
        end
        surface = strrep(names.surface, '_', '');
        if ~isempty(info.(surface)),
            throw(AmbiguousSurface);
        else
            info.(surface) = catfile(rel2abs(surfacesPath), files{i});
        end
    elseif ~isempty(regexpi(files{i}, patDense)),
        % Sparse surface files
        pat = '^(?<id>\d+)-(?<surface>[^-]+)-dense.tri$';
        names = regexpi(files{i}, pat, 'names');
        if ~isempty(info.id),
            if ~strcmpi(names.id, info.id),
                error('id does not match across surface files')
            end
        else
            info.id = names.id;
        end
        surface = strrep(names.surface, '_', '');
        if ~isempty(info.([surface 'dense'])),
            error('id does not match across surface files')
        else
            info.([surface 'dense']) = catfile(rel2abs(surfacesPath), ...
                files{i});
        end
        
    else
        continue;
    end
end


end