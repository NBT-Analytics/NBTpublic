function x = est07_SAwessCI(MAP,SA,HR)
% EST07_SAwessCI  CO estimator 7: Wesseling's systolic area with impedance correction
%
%   In:   MAP  <nx1> vector  --- beat-to-beat mean arterial pressure
%         SA   <nx1> vector  --- beat-to-beat systolic pressure area
%         HR   <nx1> vector  --- beat-to-beat heart rate
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = (163+HR-0.48*MAP).*SA.*HR;