%  [intx,inty] = nbt_loadintxinty(loc_file)
%   Computes cartesian coordinates of electrode location 
%
% Usage:
%
%  [intx,inty] = nbt_loadintxinty(loc_file)
%
%Inputs:
%     loc_file : struct containing electrode location coordinates and other
%     information
% 
% For example: [inty,intx]=nbt_loadintxinty(Info.Interface.EEG.chanlocs);


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

function [intx,inty] = nbt_loadintxinty(loc_file)
if ischar(loc_file)
    % readlocs reads electrode location coordinates and other information from a
    % file.
    [tmpeloc labels Th Rd indices] = readlocs( loc_file);
elseif isstruct(loc_file) % a locs struct
    [tmpeloc labels Th Rd indices] = readlocs( loc_file );
    % Note: Th and Rd correspond to indices channels-with-coordinates only
else
    error('loc_file must be a EEG.locs struct or locs filename');
end
%--- convert degrees to radians
Th = pi/180*Th;                              
% allchansind = 1:length(Th);
%--- Transform polar to Cartesian coordinates.
[intx,inty] = pol2cart(Th,Rd);
%
% intx=[  0.2581
%     0.2394
%     0.2174
%     0.1836
%     0.1368
%     0.0893
%     0.0360
%     0.3021
%     0.2764
%     0.2385
%     0.1999
%     0.1368
%     0.0780
%     0.3287
%     0.2831
%     0.2466
%     0.3586
%     0.2385
%     0.1836
%     0.1308
%     0.3287
%     0.2764
%     0.2174
%     0.1665
%     0.3021
%     0.2394
%     0.1685
%     0.1170
%     0.0701
%     0.0232
%     -0.0156
%     0.2581
%     0.1742
%     0.0995
%     0.0426
%     0.0073
%     -0.0356
%     0.1911
%     0.0395
%     0.0011
%     -0.0226
%     -0.0593
%     0.1532
%     0.0746
%     -0.0813
%     -0.0756
%     -0.0856
%     0.1722
%     0.0306
%     -0.1622
%     -0.1430
%     -0.1187
%     -0.0957
%     -0.0767
%     -0.0474
%     -0.1671
%     -0.1911
%     -0.2145
%     -0.1892
%     -0.1543
%     -0.1281
%     -0.1592
%     -0.2815
%     -0.2804
%     -0.2605
%     -0.2187
%     -0.1864
%     -0.3739
%     -0.3415
%     -0.2923
%     -0.2361
%     -0.2049
%     -0.4149
%     -0.3683
%     -0.3013
%     -0.2361
%     -0.1864
%     -0.1281
%     -0.0767
%     -0.0156
%     -0.4236
%     -0.3683
%     -0.2923
%     -0.2187
%     -0.1543
%     -0.0957
%     -0.0356
%     -0.4149
%     -0.3415
%     -0.2605
%     -0.1892
%     -0.1187
%     -0.0593
%     -0.3739
%     -0.2804
%     -0.2145
%     -0.1430
%     -0.0856
%     -0.2815
%     -0.1911
%     -0.1622
%     -0.0756
%     -0.0226
%     0.0073
%     0.0232
%     0.0360
%     -0.1671
%     -0.0813
%     0.0011
%     0.0426
%     0.0701
%     0.0780
%     0.0306
%     0.0746
%     0.0395
%     0.0995
%     0.1170
%     0.1308
%     0.1722
%     0.1532
%     0.1911
%     0.1742
%     0.1685
%     0.1665
%     0.2475
%     0.3945
%     0.3945
%     0.2475
%     0];
%
% inty=[ 0.2706
%     0.1888
%     0.1100
%     0.0737
%     0.0356
%     0
%     -0.0283
%     0.1594
%     0.0839
%     0.0501
%     0
%     -0.0356
%     -0.0584
%     0.0441
%     0
%     0
%     0
%     -0.0501
%     -0.0737
%     -0.0977
%     -0.0441
%     -0.0839
%     -0.1100
%     -0.1233
%     -0.1594
%     -0.1888
%     -0.1756
%     -0.1561
%     -0.1237
%     -0.0892
%     -0.0445
%     -0.2706
%     -0.2701
%     -0.2287
%     -0.1832
%     -0.1409
%     -0.0917
%     -0.3466
%     -0.3338
%     -0.2560
%     -0.1946
%     -0.1511
%     -0.4131
%     -0.3990
%     -0.3184
%     -0.2405
%     -0.1914
%     -0.4589
%     -0.4632
%     -0.2734
%     -0.2010
%     -0.1539
%     -0.0995
%     -0.0510
%     0.0000
%     -0.4198
%     -0.3363
%     -0.2249
%     -0.1530
%     -0.1048
%     -0.0548
%     0.0000
%     -0.3490
%     -0.2581
%     -0.1662
%     -0.1030
%     -0.0468
%     -0.2211
%     -0.1585
%     -0.0930
%     -0.0393
%     0.0000
%     -0.1068
%     -0.0490
%     0.0000
%     0.0393
%     0.0468
%     0.0548
%     0.0510
%     0.0445
%     0.0000
%     0.0490
%     0.0930
%     0.1030
%     0.1048
%     0.0995
%     0.0917
%     0.1068
%     0.1585
%     0.1662
%     0.1530
%     0.1539
%     0.1511
%     0.2211
%     0.2581
%     0.2249
%     0.2010
%     0.1914
%     0.3490
%     0.3363
%     0.2734
%     0.2405
%     0.1946
%     0.1409
%     0.0892
%     0.0283
%     0.4198
%     0.3184
%     0.2560
%     0.1832
%     0.1237
%     0.0584
%     0.4632
%     0.3990
%     0.3338
%     0.2287
%     0.1561
%     0.0977
%     0.4589
%     0.4131
%     0.3466
%     0.2701
%     0.1756
%     0.1233
%     0.3348
%     0.2221
%     -0.2221
%     -0.3348
%     0];
end