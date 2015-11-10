% Copyright (C) 2011 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
function nbt_DeleteInfoFiles(startpath)
d= dir (startpath);
for j=3:length(d)
    if (d(j).isdir )
        nbt_DeleteInfoFiles([startpath,'\', d(j).name ]);
    else
        b = strfind(d(j).name,'mat');
        cc= strfind(d(j).name,'info');
        
        if (length(b)~=0  && length(cc)~=0)
            delete([startpath , '/',d(j).name]);
        end
    end
end
end