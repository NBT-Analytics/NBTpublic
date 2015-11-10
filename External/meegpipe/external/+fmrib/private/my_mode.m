% function that gets you the mode of any (non-absolute) vector.
%
% For monitoring purposes, there are different ways to call this function.
%
% mode=my_mode(v,maxv)
% produces just the mode, and -1 for the fh if you call it.
%
% [mode fh]=my_mode(v,maxv,1)
% produces the mode and a histogram figure; handle fh, with vis. 'on!'.
%
% [mode fh]=my_mode(v,maxv,1,1)
% produces the mode and a fh, with visibility 'off'.
% 
% Currently the binsize is 250. You might need a lot of data points to
% have a good histogram count, otherwise this function might not work that 
% well. Optionall, set binsize to 500 (but then need even more datapoints.)
%
% useful values for maxv is about 5-10 times the median of the abs of the
% hilbert transform of v. Or just take the 5-10 times the median of the
% rectified signal.
% The estimate for the mode is relatively independent wrt this choice;
% However, since the function uses a # of data points around the mode, it
% is recommended not to take this too low (not a good approximation of the
% peak) or too high (the peak has too few data points for a good fit).

function varargout=my_mode(varargin)


    if numel(varargin)==1;
        error('you must also specify the max bin');
    end

    v=varargin{1};
    maxbin=varargin{2};
    
    if numel(varargin)>2
        verbosity=varargin{3};
    else
        verbosity=0;
    end
    
    if numel(varargin)>3
        val_visible='off';
    else
        val_visible='on';
    end
    
        
    % keyboard;
    % hilbert transform
    h=hilbert(v);
    
    % empirical bin-size.
    totbins=round(numel(v)/20);
    
    % totbins=30;
    
    % define edges with res of 0.01.
    steps=maxbin/totbins;
    edges=0:steps:maxbin;
    
    % do histogram-count
    count=histc(abs(h),edges);
    
    
    % fit the rayleigh dbs function to it!
    
    
    % find fullest bin (or count...)
    % in case of lots of noise, do t 
    fullestcount=find(count>=max(count)>0.8);
    fullestcount=round(mean(fullestcount));

    boundaries=ceil(fullestcount*[0.5 1.5]);
    
        
    % keyboard;
    expdata=count(boundaries(1):boundaries(2));
    
    
    % we got our experimental data. now fit a model!
    % this is the model:
    % offset-scale*(x0-(1:numel(expdata))).^2
    
    % determine sensible starting values.
    % starting estimate for offset:
    ps(1) = max(expdata);
    
    % starting value for the bin:
    ps(3) = find(expdata==max(expdata),1);
    
    % starting value for the scale:
    ps(2) = (max(expdata)-min(expdata))/ps(3)^2;
    
    P=fminsearch(@(p) my_quadratic_function(p,expdata,ps),ps./ps);
    P=P.*ps;
    
    % the above is kind of... excessive, for the current purposes. Since we
    % only try to do a quadratic fit, the matlab function polyfit works
    % about equally well or even better! (use a polyfit 2 to gain the 3
    % parameters.)
    % this might be addressed in a future revision.
    
    % even though this approach is cannon-balling the fruit-fly, it is at
    % least illustrative on how to use fminsearch to solve similar problems
    % with non-polynomial or non-analytical functions.
    
    
    
    % we're interested in P(3) only; ie; the x0 or the mode of the
    % distribution.
    % convert it to normal int value.
    x0int = P(3)+boundaries(1)-1;
    
    % and then convert it to the mode.
    mode = (x0int-1)*steps;
    
    % dealing with the report of all that's happened:
    if verbosity==1
        
        fh=figure;
        set(fh,'visible',val_visible);

        plot(count,'color',[0.8 0.8 0.8],'linewidth',2,'linestyle','-');
        hold on;
        p=raylpdf(1:numel(count),x0int);
        line(x0int*[1 1],get(gca,'ylim'),'color','k');
        plot(boundaries(1)-1+(1:numel(expdata)),expdata,'color',[0.3 0.3 0.3],'linewidth',2);
        plot(p/max(p)*P(1),'color',[0 0 0],'linewidth',1.5);
        legend({['experimental data, median = ' num2str(median(abs(h)))],['rayleigh fit, mode = ' num2str(mode)]});
        % set(gca,'xticklabel',{num2str(0*steps),num2str(100*steps),num2str(200*steps),num2str(300*steps),num2str(400*steps),num2str(500*steps),num2str(600*steps)});

        
%         set(gca,'xtick',round((0:1:floor(steps*totbins))/steps));
%         set(gca,'xticklabel',num2cell((round((0:1:floor(steps*totbins))'))));
        title(['binsize = ' num2str(totbins) ', max = ' num2str(maxbin)]);
            
    end
    
    if numel(varargin)==2
        fh=-1;
    end
    
    varargout={mode,fh};



        
        
    
    

    
    
    