function L=my_quadratic_function(p,expdata,ps)


    % re-scale, for fminsearch works best with values 0-1.
    p=p.*ps;

    % this function uses TWO parameters.
    % the first one, the 'mode' of the rayleigh distribution.
    % the second one, how much the raylpdf needs to be re-scaled to fit the
    % count experimental data the best way.
    offset=p(1);         % starting value; 2.
    scale=p(2);     % starting value; 1.
    x0=p(3);

    
    % define model and experimental data.
    model=offset-abs(scale)*(x0-(1:numel(expdata))).^2;
    

    % ss of model-expdata.
    L=sum((model-expdata).^2);
    
    % figure;plot(model);hold on;plot(expdata);
    
    % disp(L);