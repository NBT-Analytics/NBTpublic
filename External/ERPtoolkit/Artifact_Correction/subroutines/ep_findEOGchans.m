function eog=ep_findEOGchans(eloc);
%  eog=ep_findEOGchans(eloc);
%       Finds EOG channels from electrode coordinates from .ced file.
%
%Inputs:
%  eloc          : structure containing the channel names and locations.
%                 Assumes only electrodes present, no fiducials.
%   .X           : x-coordinate
%   .Y           : y-coordinate
%   .Z           : z-coordinate
%
%Outputs:
%   eog.LUVEOG: left upper vertical EOG channel
%   eog.RUVEOG: right upper vertical EOG channel
%   eog.LLVEOG: left lower vertical EOG channel
%   eog.RLVEOG: right lower vertical EOG channel
%   eog.LHEOG: left horizontal EOG channel
%   eog.RHEOG: right horizontal EOG channel
%

%History:
%  by Joseph Dien (2/11/09)
%  jdien07@mac.com

%standard EOG locations based on EGI 128 channel GSN200 net
standard.LUVEOG=[9.2995, 4.0822, -1.7159];
standard.RUVEOG=[9.2995, -4.0822, -1.7159];
standard.LLVEOG=[7.1654, 3.3413, -8.0735];
standard.RLVEOG=[7.1654, -3.3413, -8.0735];
standard.LHEOG=[5.5373, 6.0007, -5.7386];
standard.RHEOG=[5.5373, -6.0007, -5.7386];

x=[eloc.X];
y=[eloc.Y];
z=[eloc.Z];

nChan=length(eloc);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.LUVEOG(1))^2+(y(chan)-standard.LUVEOG(2))^2+(z(chan)-standard.LUVEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.LUVEOG=IX(1);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.RUVEOG(1))^2+(y(chan)-standard.RUVEOG(2))^2+(z(chan)-standard.RUVEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.RUVEOG=IX(1);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.LLVEOG(1))^2+(y(chan)-standard.LLVEOG(2))^2+(z(chan)-standard.LLVEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.LLVEOG=IX(1);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.RLVEOG(1))^2+(y(chan)-standard.RLVEOG(2))^2+(z(chan)-standard.RLVEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.RLVEOG=IX(1);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.LHEOG(1))^2+(y(chan)-standard.LHEOG(2))^2+(z(chan)-standard.LHEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.LHEOG=IX(1);

elecDistances = zeros(nChan,1);
for chan = 1:nChan
        elecDistances(chan)=sqrt((x(chan)-standard.RHEOG(1))^2+(y(chan)-standard.RHEOG(2))^2+(z(chan)-standard.RHEOG(3))^2);
end;
[B IX]=sort(elecDistances);
eog.RHEOG=IX(1);

