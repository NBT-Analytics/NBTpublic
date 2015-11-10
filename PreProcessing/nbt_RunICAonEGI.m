
% plot_TF_and_spectrum_one_channel(Signal,Info,channel_nr,frequency_interval,nFFT,plotting)

% Inputs:
% Signal is a Signal object
% Info is corresponding Info object
% channel_nr is the number of the channle you want to use
% frequency_interval is the frequency interval that is used too depict the 
%       time-frequency representation and the power spectrum.
% nFFT is number of fast fourier transforms, higher this number and the frequency resolution goes up,
%         but the time resolution goes down
% plotting. If plotting = 1, then a pdf plot will be generated in current
% directory, and opened.

% This function plot a time frequency representation and power spectrum of
% signal in channel channel_nr in the Signal object, in the frequency interval frequency_interval;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RunICAonEGI(ReseacherID,Fs,resampleFreq)
% File format is defined as <Project ID>.<Subject ID>.<Recording date
% YYMMDD>.<Condition>.mat
% Please select folder with EGI .mat files.



% specify folder containing files
directoryname = uigetdir('C:\','Please select a folder with EGI signal files');
d = dir(directoryname);
cd ([directoryname]);

% looping through all files in folder
for j=3:length(d)
    if (~d(j).isdir)
        FileEx = strfind(d(j).name,'mat');
        if( ~isempty(FileEx))
            % Find information from filename
            FileNameIndex = strfind(d(j).name,'.');
            ProjectID = d(j).name(1:(FileNameIndex(1)-1));
            SubjectID = d(j).name((FileNameIndex(1)+2):(FileNameIndex(2)-1));
            DateRec   = d(j).name((FileNameIndex(2)+1):(FileNameIndex(3)-1));
            Condition = d(j).name((FileNameIndex(3)+1):(FileNameIndex(4)-1));

            % and load file
            load ([d(j).name])
            disp('Filename:')
            disp(d(j).name)

            % Find signal in file using the size of the signal array
            VariableList = whos;
            Signalname = [];

            for i = 1:length(VariableList(:))
                if(VariableList(i).size(1) == 129 && VariableList(i).size(2) > 1)
                    Signalname = VariableList(i).name;
                    break
                end
            end
            if (isempty(Signalname)) % i.e. no signal in file
                continue
            end

            Notes = 'ICA';



            % create NBTSignal Object 
            Signal = eval(Signalname);
            clear ([Signalname])
        %    NBTSignalObject = NBTSignal(Signal,Fs, SubjectID, 0, 129, DateRec, Condition, ReseacherID, Notes, 'EGI',ProjectID,[]);
         %   clear Signal
%% resample to 300

EEG=eeg_emptyset;

%if (~isempty(NBTSignalObject.Info))
%    EEG = NBTSignalObject.Info;
%end

EEG.nbchan = min(size(Signal));
EEG.ref =129;
EEG.srate = Fs;
EEG.trials = 1;

EEG.data = Signal;
clear Signal

EEG = eeg_checkset(EEG);
%resample signal
[EEG] = pop_resample(EEG,resampleFreq);
[EEG] = pop_reref(EEG,[]);
EEG = pop_iirfilt( EEG, 0.5, 47);




[EEG, com]=pop_runica(EEG,'icatype','runica','extended',1);

Signal = EEG.data;
EEG.data = [];

ICASignal = NBTSignal(Signal,resampleFreq, SubjectID, 0, 'averef', DateRec, Condition, ReseacherID, Notes, 'ICAfromEGI',ProjectID,EEG);
save (([d(j).name]), 'ICASignal')
        end
    end
end
end


