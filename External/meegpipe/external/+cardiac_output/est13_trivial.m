function x = est13_Lilj(PP,HR,MAP)
% EST05_Lilj  CO estimator 13: modified Liljestrand PP*HR/MAP
%
%   In:   PP    <nx1> vector  --- beat-to-beat pulse pressure
%         HR    <nx1> vector  --- beat-to-beat heart rate
%         MAP   <nx1> vector  --- beat-to-beat mean pressure
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = PP./MAP .* HR;