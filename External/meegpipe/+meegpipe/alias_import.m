function importCmd = alias_import(varargin)
% ALIAS_IMPORT - Aliased import directives
%
% ## Usage synopsis:
%
% % Import all processing nodes
% eval(meegpipe.alias_import('nodes'));
%
% ## Notes:
%
% * You can manually edit the aliases by editing the configuration file of
%   package meegpipe (meegpipe.ini).
%
%
% See also: meegpipe

import mperl.config.inifiles.inifile;
import meegpipe.get_config;
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