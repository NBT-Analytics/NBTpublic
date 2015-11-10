function x = est01_MAP(MAP)
% EST01_MAP  CO estimator 1: Mean arterial pressure
%
%   In:   MAP  <nx1> vector  --- beat-to-beat mean arterial pressure
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = MAP;