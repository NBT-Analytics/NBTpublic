function elecDistances=ep_closestChans(eloc);
%  elecDistances=closestChans(eloc);
%       computes distance from every electrode to every other one
%
%Inputs:
%  eloc          : structure containing the channel names and locations.
%                 Assumes only electrodes present, no fiducials.
%   .X           : x-coordinate  
%   .Y           : y-coordinate 
%   .Z           : z-coordinate 
%   
%Outputs:
%  elecDistances : distances to other electrodes (electrodes, electrodes)
%

%History:
%  by Joseph Dien (2/8/09)
%  jdien07@mac.com

x=[eloc.X];
y=[eloc.Y];
z=[eloc.Z];

nChan=length(eloc);

elecDistances = zeros(nChan);

for chan1 = 1:nChan-1
    for chan2 = chan1+1:nChan
        elecDistances(chan1,chan2)=sqrt((x(chan1)-x(chan2))^2+(y(chan1)-y(chan2))^2+(z(chan1)-z(chan2))^2);
        elecDistances(chan2,chan1)=elecDistances(chan1,chan2);
    end;
end;