
% eegplugin_adjust() - Plugin for filtering/removing gross
% artifacts/running ICA/running ADJUST algorithm on EEG data
%
% Usage:
%   >> eegplugin_adjust( fig, try_strings, catch_strings);
%
% Inputs:
%   
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
%
% Copyright (C) 2009 Andrea Mognon and Marco Buiatti, 
% Center for Mind/Brain Sciences, University of Trento, Italy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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


function eegplugin_adjust( fig, try_strings, catch_strings)
plotmenu = findobj(fig, 'tag', 'tools');
uimenu(plotmenu, 'label', 'ADJUST', 'callback', ...
    [try_strings.no_check '[ALLEEG,EEG,CURRENTSET,LASTCOM]= pop_ADJUST_interface( ALLEEG,EEG,CURRENTSET );eeglab redraw;' catch_strings.add_to_hist  ]);




