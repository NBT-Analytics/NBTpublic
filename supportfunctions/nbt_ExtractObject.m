%This function extracts a specific object in the caller stack
%SEE ALSO: nbt_ExtractBiomarkers

% Copyright (C) 2014  Simon-Shlomo Poil
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function ObjectList=nbt_ExtractObject(objectname)
ObjectList = cell(0,0);
s=evalin('caller','whos');
for ii=1:length(s)
    if(strcmp(s(ii).class,objectname))
        ObjectList = [ObjectList, s(ii).name];
    end
end
end