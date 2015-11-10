%usage:  split_text(Handle,Offset,Texts,maxLine,fs)
%  for example:
%  split_text(gca,0,'Split this text into several lines',15,10)
% This function splits some text into several lines with no more than
% maxLine characters per line
% 'Offset' is is the difference in height between each line printed on the
% plot. fs is font size
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

function nbt_split_text(OffsetX,OffsetY,Texts,maxLine,fs)
lin = OffsetY;
toWrite = '';
i = 1;
while  size(Texts,2) > 0
       % while size(toWrite,2) < maxLine && size(Texts,2) >0
       while size(Texts,2) >0
        [head, tail] = strtok(Texts,' ');
        % while size([toWrite,' ',head],2) < maxLine && size(tail,2) >0
        if size(toWrite,2) + 1 + size(head,2) < maxLine
            toWrite = [toWrite,' ',head];
            Texts = tail;
        else
%             toWrite = toWrite;
%             Texts = Texts;
%            toWrite = [toWrite,' ',head];
%            Texts = [toWrite(maxLine+1:end) tail];
%            toWrite = toWrite(1:maxLine);            
        break;
        end
    end
    toArray{i} = deblank(toWrite);
    i = i + 1;
    toWrite = '';
end
lin = OffsetY * floor((i-1)/2);
% lin = OffsetY * floor((i-1));
for j= 1:i-1
    text(OffsetX,lin,toArray{j},'interpreter','none','fontsize',fs,'HorizontalAlignment','center');
    lin = lin - OffsetY;
end