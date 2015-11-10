% this function tries to make an adjusting mode 'vector'; for each point in
% v, a rather hasty estimate of the mode.
% advantage is that this makes sure the mode estimate still theoretically
% estimates the noise-it-it-were-gaussian, and that it also is insensitive
% to the occurence of myocloni in the window


% the mode should be estimated with the 'least' amount of data points
% available, because i want a sliding window. However you do still need 
% a number of data points to obtain this estimate
% so we choise a low bin-size (eg, 12).
% and we put in this bin size the range 0.2*median - 1.2*median.
% we do polyfit a line through data points 1-10.
% and we take 1536 samples window, which is 1.5 seconds (quick!)
% and approx. 128 samples/bin, which should be 'enough'.
% do a polyfit on 9 data points (from 2 to 10).
% the peak should be there.

% during testing i found that 2048 samples works a bit better.
% speedup controls the interval between points where mode is estimated.
% this is then 'interp' ed. afterwards.
% bad estimates are replaced by the mean of their neighbours.

% secs=2.5;
% srate=1024;
% speedup=100;
% 
% this... should give 'reasonably robust' estimates of the mode.

% we have extreme non-white noise in this signal. So we're going to filter
% it to render the histogram a bit more 'white'.

% to improve robustness, we're going to filter the ahv with a low-pass
% filter prior to detection of myocloni with a filter.

function out=my_mode_vector(v,secs,srate,speedup)



    % hilbert transform.
    ahv=abs(hilbert(v));
    
    % fahv=filtfilt(fb,fa,ahv);
    
    % 1.5 secs of data.
    wsize=secs*srate;
    
    % speedup the fminsearch a little.
    options=optimset('fminsearch');
    options=optimset(options,'TolX',1e-3,'TolFun',1e-3,'MaxFunEvals',1200);
    
    % do steps of 200 ms. interpolate later.
    % speedup=100;
    % keep track of points.
    
    % keyboard;
    pointsf=(wsize/2+1):speedup:(numel(v)-wsize/2);
    pointsb=(numel(v)-wsize/2):-1*speedup:(wsize/2+1);
    
    points=[pointsf pointsb];
    % store the modes.
    mv=zeros(1,numel(points));

    % walk the vector ahv, detect the mode, and store it.
    indmat=zeros(numel(v),numel(points));
    modemat=zeros(numel(v),numel(points));
    for i=1:numel(points);

        ind=points(i)-wsize/2:(points(i)+wsize/2);

        % keyboard;
        t=ahv(ind);

        
        % we divide up our progess in steps of median(t)/10;
        % controversial, but we don't have enough data points to do it
        % 'neatly'.
        mt=median(t);
        steps=mt/30;
        
        % what matters is stepsize only.
        edges=0.0*steps:steps:7*mt;
        count=histc(t,edges);
        % figure;plot(count);
        
        % declare peak as point 1 (improves fitting) till it no longer is >
        % 0.5 * max of peak.
        sc=sort(count,'descend');
        range=find(count>0.05*mean(sc(1:3)),1,'first'):find(count>0.7*mean(sc(1:3)),1,'last');
        
        % en nu voor de functie!
        y=count(range);

        % figure;plot(count);hold on;plot(range,y,'r');
        
        % fminsearch search.
        % create starting values for fminsearch;
        
        % define x0.
        ps(3) = round(median(range))-min(range)+1;
        
        % define offset.
        try
            ps(1) = y(ps(3));
        catch
            keyboard
        end
    
        % define scaling.
        ps(2) = (ps(1)-y(1))/(ps(3)-1)^2;
        
        % search the minimum.
        % keyboard;
        P=fminsearch(@(p) my_quadratic_function(p,y,ps),ps./ps,options);
        P=P.*ps;
        
        % figure;plot(y);hold on;plot(P(1)-P(2)*(x-P(3)).^2,'r');

        % optionally, i could use an optimset call to speed up this
        % process.
        
        x0int = P(3)+range(1)-1;
        % this should be the right way to convert int mode to a real
        % number(mode). For N counts the # of points, between
        % (N-1)*mode/steps and N*mode/steps.
        mode = (x0int-0.5)*steps+0.0*steps;
        
        mv(i)=mode;
        
        if mode<0
            keyboard;
        end
        
        
        % disp(i);
        
        indmat(ind,i)=1;
        modemat(ind,i)=mode;
        
    end
    
    mv=sum(modemat,2)./sum(indmat,2);
    mmv=mean(mv);
    
    for i=1:size(modemat,1)
        for j=1:size(modemat,2)
        
            % if it is < 0 or > 10* mean mv, use adjacent estimates instead.
            if modemat(i,j)>10*mmv&&indmat(i,j)==1||modemat(i,j)<0&&indmat(i,j)==1
            
                % remove this particular estimate.
                keyboard;
                
                modemat(i,j)=0;
                indmat(i,j)=0;
           
                disp(sprintf('bad mode-estimate; i = %d, j = %d',i,j));
            end
            
        end
    end
    
    if sum(logical(sum(indmat,2)))<size(indmat,1)
        disp('there is an index where a mode-estimate is not applicable!');
        lasterr;
        keyboard;
    end

    
    
    
    mv=sum(modemat,2)./sum(indmat,2);
    
    out=mv';
    

    
    


