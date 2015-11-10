% nbt_movegui - This function makes sure the figure is on screen. 
% Usage
% nbt_movegui(h)
% where h is the figure handle

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2012), see NBT website (http://www.nbtwiki.net) for current email address
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

function h=nbt_movegui(h)
try
    set(h,'CreateFcn','movegui')
    figName = tempname;
    hgsave(h,figName)
    close(h)
    h = hgload(figName);
    delete([figName '.fig']);  
catch
end
end