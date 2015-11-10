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
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function [AmplitudeObject] = FindAmplitude(AmplitudeObject, SignalObject);
% Amplitude Analysis - Part of the NBT - toolbox
% [AmplitudeObject] = FindAmplitude(AmplitudeObject, Signalobject, FilteredSignal );
%% Input parameters
% AmplitudeObject         : An amplitude object
% Signalobject      : An NBTSignal object

%% output parameters
% AmplitudeObject     : Return the amplitude object with updated information.
%% ChangeLog
%$ Version 1.0 - 13. January 2009 : Modified by Simon-Shlomo Poil, simonshlomo.poil@cncr.vu.nl$
%Release 
%% Issues to be solved 
% write help
% cleanup
%******************************************************************************************************************

% See also NBTsignal

%% Copyright (c) 2008, Klaus Linkenkaer-Hansen, Simon-Shlomo Poil (Center for Neurogenomics and Cognitive Research (CNCR), VU University Amsterdam)


AmplitudeObject.MarkerValue(:,SignalObject.SubjectID) =  mean(SignalObject.Signal);
AmplitudeObject.Condition = SignalObject.Condition;
AmplitudeObject.ProjectID = SignalObject.ProjectID;
AmplitudeObject.SignalType = SignalObject.SignalType;
AmplitudeObject.DateLastUpdate = datestr(now);

end

