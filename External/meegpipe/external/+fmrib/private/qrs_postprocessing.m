function [Peaks Correlations]=qrs_postprocessing(Peaks,ECG,fs, verbose)

% Feb 2013, Modified by German Gomez-Herrero
% Add input argument verbose

if nargin < 4 || isempty(verbose), verbose = true; end

if numel(Peaks) < 1,
    Usabledata = [];
    Correlations = [];
    return;
end
% maybe also get this one out of a settings file?
CORR_THRESH = 0.9;
MIN_BEAT_INTERVAL = 0.4; % seconds
windowfactor=0.1;


N=round(windowfactor*median(diff(Peaks)));

% so what I want to do here is first to make an average waveform [-N N]
% samples around the QRS marker.
ECG=helper_filter(ECG,5,fs,'high');
ECG=helper_filter(ECG,40,fs,'low');


% this could be in the for loop; so that you take the median of only
% close-by situated BCG artifacts. But for now we shall theorize that BCG
% ISI's are fairly robustly always the same, more-or-less. (read: work for
% another time).
% range=0.8*median(diff(Peaks));

% now we wish to calculate usabledata, to see which sections of the EEG we
% could more-or-less reliably correct.
Usabledata=zeros(1,numel(ECG));

for iPeak=1:numel(Peaks)
    
    % whenever there's a heartbeat, set 'usabledata' to 1.
    % what are about 15 others?
    
    orig=iPeak;if orig<8;orig=8;elseif orig>(numel(Peaks)-7);orig=numel(Peaks)-7;end
    selectedi=[(orig-7):(orig+7)];
    
    % what was their median ISI?
    % remove 2 smallest and 2 largest (to account for bcg-marker-gaps);
    ISIs=sort(diff(Peaks(selectedi)));
    ISIs(1:3)=[];ISIs(end-2:end)=[];
    range=ceil(0.70*mean(ISIs)); % the 0.7 is completely arbitrarily chosen of course. But it SHOULD work in most cases.
    
    brange = Peaks(iPeak)-range;
    erange = Peaks(iPeak)+range;
    if brange<1;brange=1;end
    if erange>numel(ECG);erange=numel(ECG);end
    
    Usabledata(brange:erange)=1;
    
end



% let's first create a nice meanBCG signal.
% windowfactor could be obtained from a settings.ini file?
windowfactor=0.1;
N=round(windowfactor*median(diff(Peaks)));

% so what I want to do here is first to make an average waveform [-N N]
% samples around the QRS marker.
ECG=helper_filter(ECG,3,fs,'high');
ECG=helper_filter(ECG,50,fs,'low');

% filling the matrix of QRS complexes:
mat=zeros(2*N+1,numel(Peaks));
for i=1:numel(Peaks)
    
    
    ll=Peaks(i)-N;
    ul=Peaks(i)+N;
    range=1:(2*N+1);
    
    % taking care of the borders.
    if ll<1;
        range=(N-Peaks(i)+2):(2*N+1);
        ll=1;
    end
    if ul>numel(ECG);
        range=1:(N+(numel(ECG)-Peaks(i)));
        ul=numel(ECG);
    end
    
    % the actual filling.
    mat(range,i) = ECG(ll:ul);
    
end

meanQRS=mean(mat,2);




% if there are any 0's in usabledata, group those islands for later
% (hopefully) processing.
ExtraPeaks=[];
searches={};
if any(~Usabledata)
    
    
    if Usabledata(1)==0
        tmp=[-1 diff(Usabledata)];
    else
        tmp=[0 diff(Usabledata)];
    end
    
    
    begins=find(tmp==-1);
    ends=find(tmp==+1);
    if(numel(ends)<numel(begins));ends(end+1)=numel(tmp);end
    
    for i=1:numel(begins)
        
        tmp2=logical(size(tmp));
        tmp2=zeros(size(tmp));
        tmp2(begins(i):ends(i))=1;
        searches{end+1}=tmp2;
    end
    
    
    if verbose,
        fprintf('Finding peaks using cross-correlation..\n');
    end
    
    
    % so go though the searches to fit bcg artifacts.
    for i=1:numel(searches)
        
        % make a matrix...
        bsearch=find(searches{i}==1,1,'first');
        esearch=find(searches{i}==1,1,'last');
        
        % fixing some errors...
        if bsearch<1;bsearch=1;end
        if esearch>numel(ECG);esearch=numel(ECG);end
        
        
        
        corrs=zeros(1,numel(bsearch:esearch));
        for j=bsearch:esearch
            
            
            
            ll=j-N;
            ul=j+N;
            range=1:(2*N+1);
            % taking care of the borders.
            if ll<1;
                range=(N-j+2):(2*N+1);
                ll=1;
            end
            if ul>numel(ECG);
                range=1:(N+(numel(ECG)-j+1));
                ul=numel(ECG);
            end
            
            
            % calculate correlation..
            corrs(j)=prcorr2(meanQRS(range),ECG((ll):(ul)));
            
        end
        
        
        % find peaks where corrs(j)>0.90;
        % threshold it.
        corrs_thresh = corrs>CORR_THRESH;
        
        % then do the same stuff as before...
        
        if any(corrs_thresh)
            
            
            if corrs_thresh(1)==0
                tmp=[-1 diff(corrs_thresh)];
            else
                tmp=[0 diff(corrs_thresh)];
            end
            
            
            begins=find(tmp==-1);
            ends=find(tmp==+1);
            if(numel(ends)<numel(begins));ends(end+1)=numel(tmp);end
            
            searches2={};
            for k=1:numel(begins)
                
                tmp2=zeros(size(tmp));
                tmp2(begins(k):ends(k))=1;
                searches2{end+1}=tmp2;
            end
            
            if verbose,
                fprintf('I found %d possible extra peaks using correlation threshold of %.2f.\n',numel(searches2),CORR_THRESH);
            end
            
            for k=1:numel(searches2)
                
                % Explanation of what's below:
                % find in that piece of vector corrs, where the corr >
                % 0.95, the maximum sample.
                
                ExtraPeaks(end+1) = find(corrs.*searches2{k}==max(corrs.*searches2{k}));
                
                if verbose,
                    fprintf(' ... at sample: %d; Correlation with QRS Template: %.3f\n',ExtraPeaks(end),corrs(ExtraPeaks(end)));
                end
            end
            
            
        end
        
        
        
        
    end
    
    
    
    
end



% consistancy checks... u can comment this later on.
% filling the matrix of QRS complexes, but taking into account a somewhat
% larger interval...


% update the Peaks...
fprintf('Updating Peaks...\n');
Peaks = sort([Peaks ExtraPeaks]);

fprintf('Removing first and last BCG event....\n');
Peaks(1)=[];
Peaks(end)=[];


% PeakDiffMode=my_mode(diff(Peaks),3*median(diff(Peaks)));


Correlations = [];
return;

% finding peaks with abnormal ISI (they come too soon!)
fprintf('throwing away bcg artifacts in which the ISI is far too low\n');
marked=find(diff(Peaks)/fs < MIN_BEAT_INTERVAL)+1;

% marked=find((diff(Peaks)-(median(diff(Peaks))-1.5*std(diff(Peaks))))<0)+1;

Peaks(marked)=[];
fprintf('found %d such markers...\n',numel(marked));


% so what I want to do here is first to make an average waveform [-N N]
% samples around the QRS marker.
% ECG=helper_filter(ECG,5,fs,'high');
% ECG=helper_filter(ECG,40,fs,'low');
% let's first create a nice meanBCG signal.
% windowfactor could be obtained from a settings.ini file?
% windowfactor=0.1;
% 0.4 * median(diff(Peaks)) == a reasonable window to look in for assessing
% the shape of the ECG.

iteration=0;
allmarked=[];
TempPeaks=Peaks;
while iteration<2
    
    iteration=iteration+1;
    fprintf('Rejecting bad bcg artifacts (again..); iteration: %d\n',iteration);
    
    
    N=round(0.4*median(diff(TempPeaks)));
    
    mat2=[];
    % calculating correlations...
    N=round(N/2);
    
%     if isempty(TempPeaks)
%         Peaks=[];
%         Correlations=[];
%         return
%     end
%     
    mat2=zeros(2*N+1,numel(TempPeaks));
    for i=1:numel(TempPeaks)
        
        
        ll=TempPeaks(i)-N;
        ul=TempPeaks(i)+N;
        range=1:(2*N+1);
        
        % taking care of the borders.
        if ll<1;
            range=(N-TempPeaks(i)+2):(2*N+1);
            ll=1;
        end
        if ul>numel(ECG);
            range=1:(N+(numel(ECG)-TempPeaks(i)+1));
            ul=numel(ECG);
        end
        
        % the actual filling.
        mat2(range,i) = ECG(ll:ul);
        
        
    end
    
    meanQRS2=mean(mat2,2);
    TempCorrelations=[];
    for i=1:numel(TempPeaks)
        
        TempCorrelations(end+1)=prcorr2(meanQRS2,mat2(:,i));
        
    end
    
    if iteration==1 % extremely dirty programming here.
        Correlations=TempCorrelations;
    end
    
    
    % 5*mode = REALLY BAD correlation.
    marked=find(TempCorrelations<(1-6*my_mode((1-TempCorrelations),4*mean(1-TempCorrelations))));
    
    
    allmarked=[allmarked marked];
    TempPeaks(marked)=[];
    
end


fprintf('Final check revealed %d quite bad bcg markers, removing them.\n',numel(allmarked));


Peaks(allmarked)=[];
Correlations(allmarked)=[];



















