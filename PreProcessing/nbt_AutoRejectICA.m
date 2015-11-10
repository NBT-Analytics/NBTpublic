% Consists of code modified from the FASTER and ADJUST toolboxes
%ADJUST
% Copyright (C) 2009 Andrea Mognon and Marco Buiatti,
% Center for Mind/Brain Sciences, University of Trento, Italy
% Reference paper:
% Mognon, Jovicich, Bruzzone, Buiatti, ADJUST: An Automatic EEG artifact Detector based on the
% Joint Use of Spatial and Temporal features. Reviewed
%FASTER
% Copyright (C) 2010 Hugh Nolan, Robert Whelan and Richard Reilly, Trinity College Dublin,
% Ireland
% nolanhu@tcd.ie, robert.whelan@tcd.ie
%Reference paper:
%Nolan^, H., Whelan, R., & Reilly, R.B. (2010). FASTER: Fully Automated
%Statistical Thresholding for EEG artifact Rejection. Journal of Neuroscience Methods, 192, 152-162.


function [EEG,IcsRejected]  = nbt_AutoRejectICA(EEG,eyechannels,display,varargin)


EEG = eeg_checkset(EEG);

if ~exist('eyechannels','var') || isempty(eyechannels)
    nrpca = inputdlg('Specify eye channels' );
    eyechannels = str2num(nrpca{1});
end
if isempty(varargin)
    lag=2;
    thr = 3.5;
elseif ~isempty(varargin) && length(varargin) == 1
    lag = varargin{1}; % get epoch length
    thr = 3.5;
elseif ~isempty(varargin) && length(varargin) == 2
    lag = varargin{1}; % get epoch length
    thr = varargin{2}; % get faster z-score threshold
end
%% Faster toolbox
list_properties = component_properties(EEG,eyechannels,[48 50]);
rejection_options.measure=ones(1,size(list_properties,2));
rejection_options.z=thr*ones(1,size(list_properties,2)); %note different threshold than normal = 3
[IcaRej] = min_z(list_properties,rejection_options);
FASTERicaRej = find(IcaRej);

%% Adjust toolbox
EEGold = EEG;
% first epoch data

ntrials=floor((EEG.xmax-EEG.xmin)/lag);
nevents=length(EEG.event);
for index=1:ntrials
    EEG.event(index+nevents).type=[num2str(lag) 'sec'];
    EEG.event(index+nevents).latency=1+(index-1)*lag*EEG.srate; %EEG.srate is the sampling frequency
    latency(index)=1+(index-1)*lag*EEG.srate;
end;

EEG=eeg_checkset(EEG,'eventconsistency');

EEG = pop_epoch( EEG, {  [num2str(lag) 'sec']  }, [0 lag], 'newname', [EEG.setname '_ep' num2str(lag)] , 'epochinfo', 'yes');
% removing baseline
EEG = pop_rmbase( EEG, []);
EEG = eeg_checkset(EEG);



topografie=EEG.icawinv'; %computes IC topographies

% Topographies and time courses normalization

disp('Normalizing topographies...')
disp('Scaling time courses...')
EEG.icaact = eeg_getica(EEG);
for i=1:size(EEG.icawinv,2) % number of ICs
    
    ScalingFactor=norm(topografie(i,:));
    
    topografie(i,:)=topografie(i,:)/ScalingFactor;
    
    if length(size(EEG.data))==3
        EEG.icaact(i,:,:)=ScalingFactor*EEG.icaact(i,:,:);
    else
        EEG.icaact(i,:)=ScalingFactor*EEG.icaact(i,:);
    end
    
end

blink=[];

horiz=[];

vert=[];

disc=[];


%GDSF - General Discontinuity Spatial Feature
GDSF = nbt_compute_GD_feat(topografie,EEG.chanlocs(EEG.icachansind),size(EEG.icawinv,2));


%SED - Spatial Eye Difference
if (~isempty(eyechannels))
[SED,medie_left,medie_right]=nbt_computeSED_NOnorm(topografie,EEG.chanlocs(EEG.icachansind),size(EEG.icawinv,2),eyechannels);
end

%SAD - Spatial Average Difference
[SAD,var_front,var_back,mean_front,mean_back]=nbt_computeSAD(topografie,EEG.chanlocs(EEG.icachansind),size(EEG.icawinv,2),size(EEG.icawinv,1));

%SVD - Spatial Variance Difference between front zone and back zone
diff_var=var_front-var_back;

%epoch dynamic range, variance and kurtosis
num_epoch=size(EEG.data,3);
K=zeros(num_epoch,size(EEG.icawinv,2)); %kurtosis

Vmax=zeros(num_epoch,size(EEG.icawinv,2)); %variance

disp('Computing variance and kurtosis of all epochs...')

for i=1:size(EEG.icawinv,2) % number of ICs
    
    for j=1:num_epoch
        
        Vmax(j,i)=var(EEG.icaact(i,:,j));
        
        K(j,i)=kurtosis(EEG.icaact(i,:,j));
        
    end
    
end


%TK - Temporal Kurtosis

disp('Temporal Kurtosis...')

meanK=zeros(1,size(EEG.icawinv,2));

for i=1:size(EEG.icawinv,2)
    if num_epoch>100
        meanK(1,i)=trim_and_mean(K(:,i));
    else
        meanK(1,i)=mean(K(:,i));
    end
    
end


%MEV - Maximum Epoch Variance

disp('Maximum epoch variance...')

maxvar=zeros(1,size(EEG.icawinv,2));
meanvar=zeros(1,size(EEG.icawinv,2));


for i=1:size(EEG.icawinv,2)
    if num_epoch>100
        maxvar(1,i)=trim_and_max(Vmax(:,i)');
        meanvar(1,i)=trim_and_mean(Vmax(:,i)');
    else
        maxvar(1,i)=max(Vmax(:,i));
        meanvar(1,i)=mean(Vmax(:,i));
    end
end

% MEV in reviewed formulation:

nuovaV=maxvar./meanvar;


soglia_GDSF=nbt_EM(GDSF);
if (~isempty(eyechannels))
soglia_SED=nbt_EM(SED);
end
soglia_SAD=nbt_EM(SAD);
soglia_K=nbt_EM(meanK);
soglia_V=nbt_EM(nbt_removeMaxMin(nuovaV));
soglia_DV = nbt_EM(diff_var);
soglia_K = nbt_EM(meanK);


%% Horizontal eye movements (HEM)
if (~isempty(eyechannels))
horiz=intersect(intersect(find(SED>=soglia_SED),find(medie_left.*medie_right<0)),...
    (find(nuovaV>=soglia_V)));
end
%% Vertical eye movements (VEM)

vert=intersect(intersect(find(SAD>=soglia_SAD),find(medie_left.*medie_right>0)),...
    intersect(find(diff_var>0),find(nuovaV>=soglia_V)));
%% Eye Blink (EB)
blink=intersect ( intersect( find(SAD>=soglia_SAD),find(medie_left.*medie_right>0) ) ,...
    intersect ( find(meanK>=soglia_K),find(diff_var>0) ));
%% Generic Discontinuities (GD)
disc=intersect(find(GDSF>=soglia_GDSF),find(nuovaV>=soglia_V));
if (~isempty(eyechannels))
ADJUSTicaRej = nonzeros( union (union(blink,horiz) , union(vert,disc)) )';
else
    ADJUSTicaRej = nonzeros( union (blink , union(vert,disc)) )';
 SED = [];
end
IcsRejected = union(FASTERicaRej,ADJUSTicaRej);
EEG= EEGold;


if(display == 1)
    figure('Numbertitle', 'off', 'Name','FASTER ICA analysis','Units','pixels','Position', [100, 600, 800, 300])
    linew = 2;
    plot((list_properties(:,1)-mean(list_properties(:,1)))/std(list_properties(:,1)),'r','linewidth',linew)
    hold on
    plot(1:size(list_properties,1),(list_properties(:,2)-mean(list_properties(:,2)))/std(list_properties(:,2)),'b','linewidth',linew)
    plot(1:size(list_properties,1),(list_properties(:,3)-mean(list_properties(:,3)))/std(list_properties(:,3)),'g','linewidth',linew)
    plot(1:size(list_properties,1),(list_properties(:,4)-mean(list_properties(:,4)))/std(list_properties(:,4)),'m','linewidth',linew)
    plot(1:size(list_properties,1),(list_properties(:,5)-mean(list_properties(:,5)))/std(list_properties(:,5)),'y','linewidth',linew)
    plot(1:size(list_properties,1),thr*ones(1,size(list_properties,1)),'k','linewidth',linew)
    plot(1:size(list_properties,1),-thr*ones(1,size(list_properties,1)),'k','linewidth',linew)
    set(gca,'XTick',1:size(list_properties,1))
    set(gca,'XTickLabel',1:size(list_properties,1))
    ylabel('FASTER: Z-score')
    xlabel('ICA components')
    h = legend('Median gradient value','Mean slope around the LPF band','Kurtosis of spatial map','Hurst exponent','Eye channels correlation','Threshold',...
        'Location', 'EastOutside');
    set(h,'fontsize',8)
    grid off
    axis tight
    pop_eegplot(EEG,0,1,1);
    
    [EEG] = nbt_pop_selectcomps_ADJ( EEG, 1:size(EEG.icawinv,2), union(FASTERicaRej,ADJUSTicaRej), horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        0, 0, soglia_V, maxvar, 0, 0 );


else
    EEG = pop_subcomp(EEG, union(FASTERicaRej,ADJUSTicaRej), 0); 

end

end