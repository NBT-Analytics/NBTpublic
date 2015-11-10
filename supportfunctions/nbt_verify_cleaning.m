function [B_error,chans_faster,additional_student_chans,faster_student_chans,eye_student_chans,duration_faster_percent,duration_student_percent] = nbt_verify_cleaning
PathName1 = [];
PathName2 = [];
FileName1 = [];
StudentSignalName = [];

StudentSignalName = 'CleanedSignal'; %To comment
StudentSignalName = [ StudentSignalName 'Info'];
if isempty(PathName1) & isempty(FileName1)
[FileName1,PathName1] = uigetfile('*.mat','Select Reference SignalInfo file ');
end
L = loadInfofile(FileName1,PathName1);

S1_info = eval(['L.','AutoICASignalInfo']);
if isempty(PathName2) 
[FileName2,PathName2] = uigetfile('*.mat','Select Student SignalInfo file ');
end
L = loadInfofile(FileName2,PathName2);
S2_info = eval(['L.',StudentSignalName]);
clear L

Analysis1 = [PathName1 S1_info.file_name,'_analysis.mat'];
[biomarker_objects1,biomarkers1] = nbt_ExtractBiomarkers(Analysis1);

Analysis2 = [PathName2 S2_info.file_name,'_analysis.mat'];
[biomarker_objects2,biomarkers2] = nbt_ExtractBiomarkers(Analysis2);

% verify signal length
disp('Check on signal length:')
duration_original = 5*60; % 5 minutes of duration
duration_faster = S1_info.Interface.EEG.pnts/S1_info.Interface.EEG.srate;
duration_student = S2_info.Interface.EEG.pnts/S2_info.Interface.EEG.srate;
duration_faster_percent = duration_faster*100/duration_original;
duration_student_percent = duration_student*100/duration_original;
disp('--- Original duration 300 seconds (5 minutes).')
disp(['--- Automatic procedure: final duration = ' num2str(round(duration_faster/0.01)*0.01) ' seconds (' num2str(round(duration_faster_percent/0.01)*0.01) '% of the original signal length)'])
disp(['--- Student procedure: final duration = ' num2str(round(duration_student/0.01)*0.01) ' seconds (' num2str(round(duration_student_percent/0.01)*0.01) '% of the original signal length)'])

% verify removed channels
disp('Check on removed channels:')
chans_eyes = [ 8 14 21 25 125 126 127 128 ];
chans_faster = find(S1_info.BadChannels)';
chans_student = find(S2_info.BadChannels)';
join_faster_and_eyes_chans = sort([chans_eyes chans_faster]);
k = 1;
additional_student_chans = [];
for i = 1:length(chans_student)
    paired_chans = find(join_faster_and_eyes_chans == chans_student(i));
    if isempty(paired_chans)
        additional_student_chans(k) =  chans_student(i);
        k = k+1;
    end
end
k = 1;
faster_student_chans = [];
for i = 1:length(chans_student)
    paired_chans = find(chans_faster == chans_student(i));
    if ~isempty(paired_chans)
        faster_student_chans(k) =  chans_student(i);
        k = k+1;
    end
end

k = 1;
eye_student_chans = [];
for i = 1:length(chans_student)
    paired_chans = find(chans_eyes == chans_student(i));
    if ~isempty(paired_chans)
        eye_student_chans(k) =  chans_student(i);
        k = k+1;
    end
end

disp(['--- Eyes Channels: [ ', num2str(chans_eyes) ' ]'])
disp(['--- Automatic procedure: Total Bad Channels ', num2str(length(chans_faster))])
disp(['                       : Bad Channels picked by faster [ ', num2str(sort(chans_faster)) ' ]'])
disp(['--- Student procedure: Total Bad Channels (including eye channels) = ', num2str(length(chans_student)) ])
disp(['                     : Eye Channels picked by the student [ ', num2str(sort(eye_student_chans)) ' ]'])
disp(['                     : Bad Channels picked by the student and by faster [ ', num2str(sort(faster_student_chans)) ' ]'])
disp(['                     : Bad Channels picked by the student not by faster [ ', num2str(sort(additional_student_chans)) ' ]'])

% verify amplitude values
disp('Check on absolute amplitude values ...')
disp(['--- Percent Error plot: (Student-Automatic)/Automatic*100'])
k = 1;
for i = 1:length(biomarker_objects1)
    if ~isempty(findstr(biomarker_objects1{i},'amplitude')) & isempty(findstr(biomarker_objects1{i},'Normalized'))
        biom1(k) = i;
        k = k+1;
    end
end
k = 1;
for i = 1:length(biomarker_objects2)
    if ~isempty(findstr(biomarker_objects2{i},'amplitude')) & isempty(findstr(biomarker_objects2{i},'Normalized'))
        biom2(k) = i;
        k = k+1;
    end
end

for i = 1: length(biom1) 
   [B1(:,i),Sub1,Proj1,unit{i}]=nbt_load_analysis(PathName1,[S1_info.file_name,'_analysis.mat'],[biomarker_objects1{biom1(i)},'.Channels'],@nbt_get_biomarker,[],[],[]);
end
for i = 1: length(biom2)
   [B2(:,i),Sub2,Proj2,unit{i}]=nbt_load_analysis(PathName2,[S2_info.file_name,'_analysis.mat'],[biomarker_objects2{biom2(i)},'.Channels'],@nbt_get_biomarker,[],[],[]);
end
% % abs diff
% for i = 1: length(biom2)
%     B_diff(:,i) = abs(B1(:,i)-B2(:,i))./max(abs(B1(:,i)),abs(B2(:,i)));
% end
% percent diff

for i = 1: length(biom2)
    B_error(:,i) = (B2(:,i)-B1(:,i))./B1(:,i)*100;
    B_error(find(isnan(B2(:,i))),i) = nan;
end

chanloc = S1_info.Interface.EEG.chanlocs;
% figure
[W H] = nbt_getScreenSize;
figure('Position',[10 H/3 W/2 H/2],'Name','Percent Error','numbertitle','off')
coolWarm = load('nbt_CoolWarm.mat','coolWarm');
coolWarm = coolWarm.coolWarm;
colormap(coolWarm);
k = 6;
for i = 1:length(biom1)
    hold on
    subplot(length(biom1)+1,4,k)
    topoplot(B1(:,i),chanloc,'headrad','rim');
    cl = get(gca,'clim');
    set(gca,'clim',[0 cl(2)]);
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String','\muV');
    k = k+4;
end
k = 6+1;
for i = 1:length(biom2)
    hold on
    subplot(length(biom2)+1,4,k)
    topoplot(B2(:,i),chanloc,'headrad','rim');
    cl = get(gca,'clim');
    set(gca,'clim',[0 cl(2)]);
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String','\muV');
    k = k+4;
end
k = 6+2;
for i = 1:length(biom2)
    hold on
    subplot(length(biom2)+1,4,k)
    topoplot(B_error(:,i),chanloc,'headrad','rim');
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String','%');
    k = k+4;
end
% titles
subplot(length(biom1)+1,4,2)
text(0.5,0.5,'Automatic','fontweight','bold')
axis off
subplot(length(biom1)+1,4,3)
text(0.5,0.5,'Student','fontweight','bold')
axis off
subplot(length(biom1)+1,4,4)
text(0.5,0.5,'Percent Error','fontweight','bold')
axis off
subplot(length(biom1)+1,4,5)
text(0.1,0.5,regexprep(biomarker_objects1{biom1(1)},'_',' '),'fontweight','bold')
axis off
subplot(length(biom1)+1,4,9)
text(0.1,0.5,regexprep(biomarker_objects2{biom2(2)},'_',' '),'fontweight','bold')
axis off
subplot(length(biom1)+1,4,13)
text(0.1,0.5,regexprep(biomarker_objects1{biom1(3)},'_',' '),'fontweight','bold')
axis off
subplot(length(biom1)+1,4,17)
text(0.1,0.5,regexprep(biomarker_objects2{biom2(4)},'_',' '),'fontweight','bold')
axis off
subplot(length(biom1)+1,4,21)
text(0.1,0.5,regexprep(biomarker_objects1{biom1(5)},'_',' '),'fontweight','bold')
axis off



%----------------------
function L = loadInfofile(FileName,PathName)
    if isempty(findstr(FileName,'info'))
        if isempty(findstr(FileName,'_'))
            L = load([PathName filesep FileName(1:end-4) '_info.mat']);
        else
            pos = findstr(FileName,'_');
            L = load([PathName filesep FileName(1:pos-1) '_info.mat']);
        end
    else
        L = load([PathName filesep FileName]);
    end
end
end