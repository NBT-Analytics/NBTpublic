% nbt_AddChan(Signal,SignalInfo, DataToAdd, AddIndex)
%
%
%
% Usage:
%
%
% Inputs:
%
%    
% Outputs:
%
% Example:
%
%
% References:
% 
% See also: 
%
  
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2012), see NBT website for current
% email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2012 Simon-Shlomo Poil  
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
% ---------------------------------------------------------------------------------------
function [Signal, SignalInfo] =nbt_AddChan(Signal,SignalInfo, DataToAdd, AddIndex, OldChanlocs)

[AddIndexS, SortIndex] = sort(AddIndex); 

% Update Signal
for mm = 1:length(AddIndex)
   Signal = [Signal(:,1:(AddIndexS(mm)-1)) DataToAdd(:,SortIndex(mm)) Signal(:,AddIndexS(mm):end)];
end

% Update SignalInfo
SignalInfo.Interface.number_of_channels = size(Signal,2);
SignalInfo.Interface.EEG.nbchan = SignalInfo.Interface.number_of_channels;
SignalInfo.Interface.EEG.chanlocs = OldChanlocs;
end
