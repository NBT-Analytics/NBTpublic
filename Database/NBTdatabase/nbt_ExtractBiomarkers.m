
% This function extracts a list of biomarkers in the caller stack
% SEE ALSO: nbt_ExtractObject

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

function [BiomarkerObjects,Biomarkers]=nbt_ExtractBiomarkers(s)
BiomarkerObjects = cell(0,0);
error(nargchk(0,1,nargin))
if(~exist('s','var'))
    s=evalin('caller','whos');
  counter=1;
for ii=1:length(s)
    if(strcmp(superclasses(s(ii).class),'nbt_Biomarker')) 
        BiomarkerObjects = [BiomarkerObjects, s(ii).name];
        Biomarkers{counter}=evalin('caller',[s( ii ).name,'.Biomarkers']);
        counter=counter+1;
    end
end
    
else
    load(s)
    s = whos;
      counter=1;
      
% temporary adjustement
for ii=1:length(s)
    if(strcmp(superclasses(s(ii).class),'nbt_Biomarker')) & ~strcmp(s(ii).class,'nbt_questionnaire')
        BiomarkerObjects = [BiomarkerObjects, s(ii).name];
        Biomarkers{counter}=eval([s( ii ).name,'.Biomarkers']);
        counter=counter+1;
    elseif (strcmp(superclasses(s(ii).class),'nbt_Biomarker')) & strcmp(s(ii).class,'nbt_questionnaire')
        BiomarkerObjects = [BiomarkerObjects, s(ii).name];
        Biomarkers{counter}={'Answers'};
        counter=counter+1;
        
    end
end
end


end