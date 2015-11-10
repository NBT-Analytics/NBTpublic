% if the product of the extra realignment step already gives you a decent
% ECG template waveform, then maybe we can improve upon that with a sliding
% correlation window that tries to match it.
% this extra step is called:
%
% qrs_improvement_slidingwindow(Peaks,ecg,fs);

function Peaks = qrs_improvement_slidingwindow(Peaks,ECG,fs);


% PRELIM: do some basic filtering of the ECG signal/remove
% ultrahighfrequency noise and drift, as well?






% windowfactor could be obtained from a settings.ini file?
windowfactor=0.1;

N=round(windowfactor*median(diff(Peaks)));


% first obtain the average QRS complex we-re going to use.
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


% also take into account the likelihood that there's going to be a next
% heartbeat??
% corr_vals=zeros(size(ECG));

% let us try convolution.

% positions = [(floor(numel(meanQRS)/2)+1): 1 : (numel(ECG)-floor(numel(meanQRS)/2)) ];
% 
% 
% 
% for i=1:numel(positions)
% 
%     
%     % calculate the corr.
%     tvec=
%     prcorr2
%     
%     
%     
% end




% what do i want to do here:

% a) calculate an average template waveform. Use the same 0.1 factor as in
% the other function. Maybe try to import/load that; that'd be for another
% time, maybe? -- see how German does that. probablty with some function.

