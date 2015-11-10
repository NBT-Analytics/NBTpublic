% nbt_getline(varargin) Select points with mouse.

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and 
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------


function [x,y] = nbt_getline(varargin)

global GETLINE_FIG GETLINE_AX GETLINE_H

if ((nargin >= 1) && (ischar(varargin{1})))
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETLINE_AX = gca;
    GETLINE_FIG = ancestor(GETLINE_AX, 'figure');
end

% Let figure get focus
figure(GETLINE_FIG);

% Remember figure state
state = uisuspend(GETLINE_FIG);

% Set up callbacks
[pointerShape, pointerHotSpot] = CreatePointer;
set(GETLINE_FIG, 'WindowButtonDownFcn', 'nbt_getline(''FirstButtonDown'');', ...
    'Pointer', 'custom', ...
    'PointerShapeCData', pointerShape, ...
    'PointerShapeHotSpot', pointerHotSpot);

GETLINE_H = line('Parent', GETLINE_AX, ...
    'XData', [], ...
    'YData', [], ...
    'Visible', 'off', ...
    'Clipping', 'off', ...
    'Color', 'c', ...
    'LineStyle', 'none', ...
    'Marker', '+', ...
    'EraseMode', 'xor');

%wait for user click
waitfor(GETLINE_H, 'UserData', 'Completed');

x = get(GETLINE_H, 'XData');
y = get(GETLINE_H, 'YData');
x = x(:);
y = y(:);

if (ishandle(GETLINE_H))
    delete(GETLINE_H);
end

% Restore the figure state
if (ishandle(GETLINE_FIG))
    uirestore(state);
end

% Clean up the global workspace
clear global GETLINE_FIG GETLINE_AX GETLINE_H


end


function FirstButtonDown() 

global GETLINE_FIG GETLINE_AX GETLINE_H 

[x,y] = getcurpt(GETLINE_AX);

set([GETLINE_H], ...
    'XData', x, ...
    'YData', y, ...
    'Visible', 'off');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    set(GETLINE_H, 'UserData', 'Completed');
else
    set(GETLINE_FIG, 'WindowButtonDownFcn', 'nbt_getline(''NextButtonDown'');');
end
end

function NextButtonDown() 

global GETLINE_FIG GETLINE_AX GETLINE_H 

[x,y] = getcurpt(GETLINE_AX);

set([GETLINE_H], ...
    'XData', x, ...
    'YData', y, ...
    'Visible', 'off');

if (~strcmp(get(GETLINE_FIG, 'SelectionType'), 'normal'))
    set(GETLINE_H, 'UserData', 'Completed');
end

end

function [pointerShape, pointerHotSpot] = CreatePointer

pointerHotSpot = [8 8];
pointerShape = [ ...
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
    2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
    NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
    2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
    1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
    NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
end

function [xxx,yyy] = getcurpt(axHandle)
ptpt = get(axHandle, 'CurrentPoint');
xxx = ptpt(1,1);
yyy = ptpt(1,2);
end
