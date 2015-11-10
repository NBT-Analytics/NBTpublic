
% pop_ADJUST_interface() - Spectral filtering/removing gross
% artifacts/running ICA/running ADJUST algorithm on EEG data
%
% Usage:
%   >> [ALLEEG,EEG,CURRENTSET,com] = pop_ADJUST_interface (
%   ALLEEG,EEG,CURRENTSET );
%
% Inputs and outputs:
%   ALLEEG     - array of EEG dataset structures
%   EEG        - current dataset structure or structure array
%   CURRENTSET - index(s) of the current EEG dataset(s) in ALLEEG
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


function [ALLEEG,EEG,CURRENTSET,com] = pop_ADJUST_interface ( ALLEEG,EEG,CURRENTSET )

% the command output is a hidden output that does not have to
% be described in the header

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_ADJUST_interface;
	return;
end;	



%% select operations to be done: display list

messages={'Filter the data';'Remove Gross Artifacts and Perform ICA'; 'Run ADJUST'};

[Selection,ok] = listdlg('ListString',messages,'Name','ADJUST User Interface',...
    'PromptString','Select operations to be done:',...
    'OKString','Start Processing','SelectionMode','multiple','ListSize',[300 100]);


%% do operations

if ok
    
    switch num2str(Selection)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        case '1' %only perform lpf 
                         
            if ~isempty( EEG.data )

                EEG = pop_eegfilt(EEG);
                  
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
                
                eeglab redraw
                disp (['New low pass filtered dataset saved: ' EEG.setname ])
            else
                error('No loaded data');
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
            
        case '2' % only perform ICA
            
            [EEG]=interface_GA (EEG);
            
            msgbox('Gross artifacts removed from data.','ADJUST User Interface','help') 
            
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
            
            EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
            EEG = eeg_checkset(EEG);
     
            msgbox('ICA performed on data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
    
            disp(' ')
            disp('ICA performed and saved. DONE')
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        case '3' % only run ADJUST
            
            disp(' ')
            disp (['Running ADJUST on dataset ' strrep(EEG.filename, '.set', '') '.set'])
            promptstr    = { 'Enter Report file name (in quote): '};
            inistr       = { '''report.txt''' };
            result       = inputdlg2( promptstr, 'ADJUST User Interface', 1,  inistr, 'pop_AADJUST_interface');
            if length( result ) == 0 return; end;

            report   	 = eval( [ '[' result{1} ']' ] );
            
            [EEG] = interface_ADJ (EEG,report);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        case '1  2' % lpf, GA and ICA
            
            if ~isempty( EEG.data )

                EEG = pop_eegfilt(EEG);
                
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
                
                eeglab redraw
                disp (['New low pass filtered dataset saved: ' EEG.filename])
            else
                error('No loaded data');
            end
            
            [EEG]=interface_GA (EEG);
            
            msgbox('Gross artifacts removed from data.','ADJUST User Interface','help') 
            
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
            
            EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
            EEG = eeg_checkset(EEG);
        

            msgbox('ICA performed on data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
    
            disp(' ')
            disp('ICA performed and saved. DONE')
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        case '1  3' %lpf and ADJUST
             

            promptstr    = { 'Enter Report file name (in quote): '};
            inistr       = { '''report.txt''' };
            result       = inputdlg2( promptstr, 'ADJUST User Interface', 1,  inistr, 'pop_AADJUST_interface');
            if length( result ) == 0 return; end;

            report   	 = eval( [ '[' result{1} ']' ] );
            
            if ~isempty( EEG.data )

                EEG = pop_eegfilt(EEG);
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
                eeglab redraw
                disp (['New low pass filtered dataset saved: ' EEG.filename])
            else
                error('No loaded data');
            end
           
            [EEG] = interface_ADJ (EEG,report);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        case '2  3' %GA, ICA and ADJUST
            
            [EEG]=interface_GA (EEG);
            msgbox('Gross artifacts removed from data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
            
            EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
            EEG = eeg_checkset(EEG);
        

            msgbox('ICA performed on data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
    
            disp(' ')
            disp('ICA performed and saved. DONE')
            
            disp(' ')
            disp (['Running ADJUST on dataset ' strrep(EEG.filename, '.set', '') '.set'])
            promptstr    = { 'Enter Report file name (in quote): '};
            inistr       = { '''report.txt''' };
            result       = inputdlg2( promptstr, 'ADJUST User Interface', 1,  inistr, 'pop_AADJUST_interface');
            if length( result ) == 0 return; end;

            report   	 = eval( [ '[' result{1} ']' ] );
            
                       
            [EEG] = interface_ADJ (EEG,report);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
        case '1  2  3' % entire processing
            
                         
            promptstr    = { 'Enter Report file name (in quote): '};
            inistr       = { '''report.txt''' };
            result       = inputdlg2( promptstr, 'ADJUST User Interface', 1,  inistr, 'pop_AADJUST_interface');
            if length( result ) == 0 return; end;

            report   	 = eval( [ '[' result{1} ']' ] );
           
            if ~isempty( EEG.data )

                EEG = pop_eegfilt(EEG);
                [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
                eeglab redraw
                disp (['New low pass filtered dataset saved: ' EEG.filename])
            else
                error('No loaded data');
            end
            
            [EEG]=interface_GA (EEG);
            msgbox('Gross artifacts removed from data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
            
            EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
            EEG = eeg_checkset(EEG);
        

            msgbox('ICA performed on data.','ADJUST User Interface','help')    
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);
            eeglab redraw
    
            disp(' ')
            disp('ICA performed and saved. DONE')
            
            [EEG] = interface_ADJ (EEG,report);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    end
else disp('No processing selected.'); return;
    
end       
 
  

% return the string command
% -------------------------
com = sprintf('pop_ADJUST_interface( %s );', EEG.filename);

return;
