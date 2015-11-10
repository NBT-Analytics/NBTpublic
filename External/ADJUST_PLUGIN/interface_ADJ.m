
% interface_ADJ() - Run ADJUST algorithm on EEG data
%
% Usage:
%   >> [EEG,dir,filename]=interface_ADJ(EEG,report,dir,filename);
%
% Inputs and outputs:
%   EEG        - current dataset structure or structure array
%
% Input:
%   report     - (string) report file name
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

function [EEG,dir,filename] = interface_ADJ (EEG,report,dir,filename)

% Epoching

    % ----------------------------------------------------
    % | NOTE: epochs are extracted ONLY to make          |
    % | ArtifactADJUST run                               |
    % ----------------------------------------------------
    
if size(EEG.data,3)==1 % epochs must be extracted
    
        lag=5; %epoch duration (in seconds)
        
        % check whether '5sec' events are present
        si=0; 
        for i=1:length(EEG.event) 
            if(strcmp(EEG.event(1,i).type, '5sec')==1) 
                si=1; 
            end
        end
        if si==0 %add events
            ntrials=floor((EEG.xmax-EEG.xmin)/lag);
            nevents=length(EEG.event);
            for index=1:ntrials
                EEG.event(index+nevents).type='5sec';
                EEG.event(index+nevents).latency=1+(index-1)*lag*EEG.srate; %EEG.srate is the sampling frequency
                latency(index)=1+(index-1)*lag*EEG.srate;
            end;
        
            EEG=eeg_checkset(EEG,'eventconsistency');
        end
        
        EEGep = pop_epoch( EEG, {  '5sec'  }, [0 lag], 'newname', [EEG.setname '_ep5'] , 'epochinfo', 'yes');
        % removing baseline
        EEGep = pop_rmbase( EEGep, []);
        EEGep = eeg_checkset(EEGep);
        


    % collects ICA data from EEG
    if isempty(EEGep.icaact)
        disp('Warning: EEG.icaact missing! Recomputed from EEG.icaweights, EEG.icasphere and EEG.data');
        % Next instruction: see eeg_checkset
        EEGep.icaact = reshape(EEGep.icaweights*EEGep.icasphere*reshape(EEGep.data(1:size(EEGep.icaweights,1),:,:),[size(EEGep.icaweights,1) size(EEGep.data,2)*size(EEGep.data,3)]),[size(EEGep.icaweights,1) size(EEGep.data,2) size(EEGep.data,3)]);
    end;

   % Now that dataset is epoched, run ADJUST
   [art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin]=ADJUST (EEGep,report);
    
    %% Saving artifacted ICs for further analysis

    nome=['List_' EEG.setname '.mat'];

    save (nome, 'blink', 'horiz', 'vert', 'disc');

    disp(' ')
    disp(['Artifact ICs list saved in ' nome]);


    % IC show & remove
    % show all ICs; detected ICs are highlighted in red color. Based on
    % pop_selectcomps.
    
    if isempty(EEG.icaact)
       
        EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
        
    end;
    
    
  
   
     EEG = pop_selectcomps_ADJ( EEG, 1:size(EEG.icaweights,1), art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin );
    

%     
%     EEG.reject=EEGep.reject;
%     EEG=eeg_checkset(EEG);
 
%%
else % data are epoched... let's work on the existing epochs
    
    % collects ICA data from EEG
    if isempty(EEG.icaact)
        disp('Warning: EEG.icaact missing! Recomputed from EEG.icaweights, EEG.icasphere and EEG.data');
        % Next instruction: see eeg_checkset
        EEG.icaact = reshape(EEG.icaweights*EEG.icasphere*reshape(EEG.data(1:size(EEG.icaweights,1),:,:),[size(EEG.icaweights,1) size(EEG.data,2)*size(EEG.data,3)]),[size(EEG.icaweights,1) size(EEG.data,2) size(EEG.data,3)]);
    end;

   % run ADJUST
   [art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin]=ADJUST (EEG,report);
    
    %% Saving artifacted ICs for further analysis

    nome=['List_' EEG.setname '.mat'];

    save (nome, 'blink', 'horiz', 'vert', 'disc');

    disp(' ')
    disp(['Artifact ICs list saved in ' nome]);


    % IC show & remove
    % show all ICs; detected ICs are highlighted in red color. Based on
    % pop_selectcomps.
    if isempty(EEG.icaact)
        disp('Warning: EEG.icaact missing! Recomputed from EEG.icaweights, EEG.icasphere and EEG.data');
        % Next instruction: see eeg_checkset
        EEG.icaact = reshape(EEG.icaweights*EEG.icasphere*reshape(EEG.data(1:size(EEG.icaweights,1),:,:),[size(EEG.icaweights,1) size(EEG.data,2)*size(EEG.data,3)]),[size(EEG.icaweights,1) size(EEG.data,2) size(EEG.data,3)]);
    end;

    [EEG]=pop_selectcomps_ADJ( EEG, 1:size(EEG.icaweights,1), art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin );
    
    

end

return


