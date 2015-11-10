
% GrossArtifactADJ() - Finds out gross artifact portions from original data
% NOTE: marks epochs in which X% of the electrodes (line 39) exceed
% threshold value Y (line 29). Change X and Y in the code if necessary.
%
% Usage:
%   >> discard = GrossArtifactADJ(EEG);
%
% Input:
%   EEG        - current dataset structure or structure array 
%                   (it is supposed to be epoched)
%
% Output:
%   discard    - vector of gross artifact epochs
%
%
% Copyright (C) 2009 Andrea Mognon and Marco Buiatti, 
% Center for Mind/Brain Sciences, University of Trento, Italy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

function discard = GrossArtifactADJ(EEG)


Nepoch=size(EEG.data,3); %num epochs
Ncomp=size(EEG.data,1); %num components

%% Epoch marking
mark=zeros(Ncomp,Nepoch); %memorizes epoch marks
for i=1:Ncomp
    for j=1:Nepoch
        if max(abs(EEG.data(i,:,j)))>150 %mark epoch if it exceeds +-150 microV; Y=150microV
            mark(i,j)=1;
        end
    end
end

%% Epoch discarding
%now check epochwise whether the amount of marked channels is > X% total channels
%if it is, discard epoch

lim=ceil(0.33*Ncomp); %threshold value (X=33%)

eliminate=zeros(1,Nepoch); %indexes of epochs to be discarded
for i=1:Nepoch
    if sum(mark(:,i))>lim
        eliminate(1,i)=1;
    end
end

index=1:Nepoch;
discard=index(eliminate==1);

