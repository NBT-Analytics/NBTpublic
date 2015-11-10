function importCmd = alias_import(varargin)
% ALIAS_IMPORT - Aliased import directives
%
% ## Usage synopsis:
%
% % Import all processing nodes
% import eegpipe.*;
% eval(alias_import('nodes'));
%
%
% See also: eegpipe

import mperl.config.inifiles.inifile;
import eegpipe.get_config;
import mperl.join;

cfg = get_config();
aliasList = parameters(cfg, 'alias');

importList = {};

for i = 1:nargin
   
    if ismember(varargin{i}, aliasList)
        thisImportList = val(cfg, 'alias', varargin{i}, true);
        if ischar(thisImportList),
            thisImportList = {thisImportList};
        end
        importList = [importList;thisImportList(:)]; %#ok<AGROW>
        
    else
        
        importList = [importList;varargin(i)]; %#ok<AGROW>
        
    end    
    
end

if isempty(importList),
    importCmd = '';
else
    importCmd = join(' ', importList);
    importCmd = ['import ' importCmd];
end



end