% function Peaks=qrsbetteralign(Peaks,ECG,fs)
%
% With this function i try to improve somewhat the alignment of the QRS
% markers (see also my_fmrib_qrsdetect.m). The thing is that that function
% detects QRS markers only with an accuracy of Fs/dL, with dL 10 and Fs
% 1000. So we can improve that a bit, and that's what I try to do here.
%
% ECG needs to be a vector that contains ECG signals.
%
% Peaks needs to be a
% vector with indices that tell you where each ECG markers starts.
%
% fs is the sampling rate. I feel I should use that as well to have a
% physical sense of time in this calculation, but I ended up not using it.
% I'll leave the argument-passing in here anyway.
%
% I have tested this only with a sampling rate of 1000 Hz, not with lower
% sampling frequencies, uet...
%
%
% Peaks = Peaks of decent bcg data. bad_ecgs = indices of
% not-so-trustworthy bcg artifacts!
%

% Feb 2013, Modified by German Gomez-Herrero
% Add input argument verbose

function [Peaks bad_ecgs]=qrsbetteralign(Peaks,ECG,fs, verbose)

if nargin < 4 || isempty(verbose),
    verbose = true;
end

% don't know yet what i'm going to do with fs.



% windowfactor could be obtained from a settings.ini file?
windowfactor=0.1;

% realignment values:
rl=zeros(size(Peaks));

% disp(1);

N=round(windowfactor*median(diff(Peaks)));

% so what I want to do here is first to make an average waveform [-N N]
% samples around the QRS marker.
ECG=helper_filter(ECG,3,fs,'high');
ECG=helper_filter(ECG,50,fs,'low');

tPeaks=Peaks;
run=0;
totalruns=3;
while run<3
    
    run=run+1;
    
    if verbose,
        fprintf('Improving alignment of markers using cross-correlation. Run: %d of %d\n',run,totalruns);
    end
    
    % temporary Peaks...
    tPeaks = tPeaks + rl;
    
    % filling the matrix of QRS complexes:
    mat=zeros(2*N+1,numel(tPeaks));
    for i=1:numel(tPeaks)
        
        
        ll=tPeaks(i)-N;
        ul=tPeaks(i)+N;
        range=1:(2*N+1);
        
        % taking care of the borders.
        if ll<1;
            range=(N-tPeaks(i)+2):(2*N+1);
            ll=1;
        end
        if ul>numel(ECG);
            range=1:(N+(numel(ECG)-tPeaks(i)));
            ul=numel(ECG);
        end
        
        % the actual filling.
        mat(range,i) = ECG(ll:ul);
        
    end
    
    meanQRS=mean(mat,2);
    
    % now to calculate the realignment.
    for i=1:numel(tPeaks)
        
        sampleQRS=mat(:,i);
        
        rl(i)=calculate_shift_between_two_vectors(sampleQRS,meanQRS);
        
    end
    
    % do some rejection; if a shift is > 3 times the STD of the rl shiftvalues,
    % put it again to 0...??
    % ... later, i do some rejection.
end

% return argument...
Peaks=tPeaks;


if verbose,
    disp('trying do find inconsistent bcg artifacts using correlation.');
end
% as a final thing, try to identify&reject some ECG markers that just are
% not trustworthy. they will also mess up the ECG removal quite a bit!!

indices = abs(detrend(std(mat)));

% calculate the 'mode' of this vector:

mode_indices=my_mode(indices,4*median(indices));

bad_ecgs = find(indices > 4 * mode_indices);

if verbose,
    fprintf('found %d inconsistent BCG artfacts; removing them.\n',numel(bad_ecgs));
end

Peaks(bad_ecgs)=[];



% throw away double markers (it tends to do that, as well..).
if verbose,
    fprintf('Finding markers that were doubly placed (to remove).\n Found: %d\n',numel(find(diff(Peaks)<10)));
end
Peaks(find([0 diff(Peaks)<10]))=[];




return;