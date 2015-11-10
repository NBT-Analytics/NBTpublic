
% interface_GA() - Removes gross artifact portions from original data.
% Handles both epoched and non-epoched EEG.
%
% Usage:
%   >> [EEG,dir,filename]=interface_GA (EEG,dir,filename);
%
% Inputs and outputs:
%   EEG        - current dataset structure or structure array
%
% Optional inputs and outputs (out of use):
%   dir        - dataset directory
%   filename   - dataset name
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

function [EEG,dir,filename]=interface_GA (EEG,dir,filename)

if size(EEG.data,3)==1 % data are continuous
    
disp(' ')
disp('Adding events to remove Gross Artifact portions')

% if exist([dir filename '.set'],'file')==0
%         disp([dir filename '.set' ' does not exist']);
%     else
%         EEG = pop_loadset([filename '.set'],dir);
%         EEG = eeg_checkset(EEG);

        lag=5; % portions duration (in seconds)
        
        % Add events '5sec'
        ntrials=floor((EEG.xmax-EEG.xmin)/lag); % number of portions
        nevents=length(EEG.event);
        
        for index=1:ntrials
            EEG.event(index+nevents).type='5sec';
            EEG.event(index+nevents).latency=1+(index-1)*lag*EEG.srate; %EEG.srate is the sampling frequency
            latency(index)=1+(index-1)*lag*EEG.srate;
        end;
        
        EEG=eeg_checkset(EEG,'eventconsistency');

        %% Extract epochs
        EEGep = pop_epoch( EEG, {  '5sec'  }, [0 lag], 'newname', [EEG.setname '_ep5'] , 'epochinfo', 'yes');
        
        % removing baseline
        EEGep = pop_rmbase( EEGep, []);
        EEGep = eeg_checkset(EEGep);
        
        % compute gross artifact epochs
        bep = GrossArtifactADJ(EEGep); % bep are gross artifact portions
        disp(['Epochs containing gross artifacts: ' num2str(bep)]);
        
        % remove gross artifacted epochs from continuous data. NOTE:
        % latency in time point, not absolute time!
        if bep>0
            for i=1:length(bep)
                ind(i,1)=latency(bep(i));
                ind(i,2)=latency(bep(i))+lag*EEG.srate-1;
            end;
            EEG = pop_select( EEG, 'nopoint',ind);
            EEG = eeg_checkset(EEG);
        else disp('No gross artifacts!');
        end

else % data are epoched... let's work on the existing epochs
    
    bep = GrossArtifactADJ(EEG); % bep are gross artifact epochs
    disp(['Epochs containing gross artifacts: ' num2str(bep)]);
        
    % remove gross artifacted epochs from data. 
        
    
        if bep>0
            EEG = pop_select( EEG, 'notrial', bep ); 
            EEG = eeg_checkset(EEG);
        else disp('No gross artifacts!');
        end;
        
end
    
    
end


