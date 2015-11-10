% nbt_wrp() - wrapper for biomarkers 
%
% Usage:
%   >>  Out = nbt_wrp(FunctionHandle, Signal, InfoObject, FunctionParameters, 'key','keyvalue');
%
% Inputs:
%   FunctionHandle     - a function handle to the biomarker function use
%   @function. The function should accept the signal (time, channelID)
%   format, and the first input spot. Function parameters should be defined
%   int he FunctionParamteres input
%   Signal     - The signal you want to analyse
%   FunctionParameteres   - parameters for the biomarker function in the
%   format {parameter1; parameter2 etc}
%
% Outputs:
%   Out     - Biomarker object
%


% Copyright (C) 2010 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

function Out = nbt_wrp(functionhandl, Signal, SignalInfo, param, varargin)
%defIn defines Signal input type

g = finputcheck( varargin, { 'oneChannel'    'string'  { 'on' 'off' }   'off'; ...
    'SignalDim' 'integer' []   1; ...
    'OutTranspose' 'string' { 'on' 'off' }   'off'; ...
    } );
if ischar(g), error(g); end;


if (g.SignalDim == 2)
    Signal = Signal';
end

options =[];
for i=lenght(param)
   options = [ options ',' num2str(param{i,1})];
end

if (strcmp(g.oneChannel, 'on'))
    % for loop
    for i=1:size(Signal,2)
       eval( ['Output(:,i) = functionhandl(Signal(:,i)' options ');']);
    end
else
    % no for loop
    eval( ['Output = functionhandl(Signal' options ');']);
end

if(strcmp(g.OutTranspose,'on'))
    Output = Output';
end

% return biomarker object
Out = nbt_biomarker;
Out.MarkerValues = Output;
Out.Numchannels = size(Signal,2);
Out.Fs = InfoObject.converted_sample_frequency;
Out.PrimaryBiomarker = 'MarkerValues';
Out.Biomarkers = {'MarkerValues'};
Out = nbt_UpdateBiomarkerInfo(Out, SignalInfo);
end