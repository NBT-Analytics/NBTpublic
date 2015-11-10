%This function returns the index of MC corrected p-values.
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2011), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
% Resturcture of GUI layout : Simon-Shlomo Poil, 2012-2013
%
% Copyright (C) 2011  Simon-Shlomo Poil
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
% -------------------------------------------------------------------------
% --------------

function Pindex=nbt_MCcorrect(p,Type)
%would be interesting to add more functions..like permutation test
pOld = p;

p = p(~isnan(p));
if(isempty(p))
    Pindex = [];
    return
end
switch Type
    case 'holm'
        %holm correct
        Pc=nbt_holmcorrect(p);
    case 'hochberg'
        %hochberg correct
        Pc = nbt_HochbergCorrect(p);
    case 'bino'
        %bino correct
        if((1-binocdf(length(find(p<0.05)),length(p),0.05))< 0.05)
            Pc = p(p<0.05);
        else
            Pc = [];
        end
    case 'bonfi'
        Pc = p;
        Pc(p > (0.05/length(p))) = nan;
        if(sum(isnan(Pc)) == length(p))
            Pc = [];
        end
end
if(~isempty(Pc))
    Pindex = nbt_searchvector(pOld,Pc);
    Pindex = unique(Pindex);
else
    Pindex = [];
end

end