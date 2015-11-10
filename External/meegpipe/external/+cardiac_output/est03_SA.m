function x = est03_SA(SA,HR)
% EST03_SA  CO estimator 3: Systolic area distributed model
%
%   In:   SA  <nx1> vector  --- beat-to-beat systolic pressure area
%         HR  <nx1> vector  --- beat-to-beat heart rate
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = SA .* HR;