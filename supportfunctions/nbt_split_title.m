%usage:  split_title(Position,Texts,maxLine,fs)
%  for example:
%  split_title(0,0,'This is the title',20,20)
% This function splits some text into several lines with no more than
% maxLine characters per line
% fs is font size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2010  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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


function nbt_split_title(Position,Texts,maxLine,fs)
toWrite = '';
tArray = '';
i = 1;
while  size(Texts,2) > 0
    [head, tail] = strtok(Texts,' ');
    toWrite = head;
    Texts = tail;
    while size(toWrite,2) < maxLine
        [head, tail] = strtok(Texts,' ');
        if size(toWrite,2) + 1 + size(head,2) < maxLine
            toWrite = [toWrite,' ',head];
            Texts = tail;
        else
            break;
        end
    end 
    tArray{i} = deblank(toWrite);
    i = i+1;
    toWrite = '';
end
title(tArray, 'position', Position,'fontsize',fs,'fontweight','bold','interpreter','none');
