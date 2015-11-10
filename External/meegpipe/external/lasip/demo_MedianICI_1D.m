% Demontration the Median-ICI denoising of a 1D signal. 
% 
% The algorithm searches for the largest local vicinity of the point of estimation 
%   where the MEDIAN assumptions fit well to the data. The estimates are calculated for 
%   a few scales and compared. The adaptive scale is defined as the largest of those 
%   for which the estimate does not differ significantly from the estimates corresponding 
%   to the smaller scales.
%
% Firstly, the MEDIAN settings should be specified:
%
%   h - is a set of scales, i.e. a number of samples which are included in signal 
%   estimation. This value should be odd, if it is even then h forces to be h+1.
%
% Secondly, Gamma parameter should be specified for the ICI rule
%   GammaICI=1.5. Small parameter Gamma leads to signal undersmoothing and a
%   large one to oversmoothing.
%
% A set available signals is: 'StepWise', 'StepWise1', 'StepWise2', 
%   'Blocks', 'Heavisine', 'Doppler', 'Bumps'.
% 
% One can specify a level of noise in 'sigma_noise'. In this example the noise 
%   probability density is a mix of two Gaussian distributions different only by 
%   their variances (sigma_noise(1) and sigma_noise(2)). The parameter 'alpha' 
%   defines a proportion of the high variance random (impulses/outliers) in the 
%   sequence of experiments:
%
%   z(x) = alpha*z0(x) + (1-alpha)*z1(x),
%
%   where z0(x) = N(0, sigma_noise(1)^2) and z1(x) = N(0, sigma_noise(2)^2), and 
%   0<=alpha<=1. For more details of noise model please read in function_InputData.
%
% Resolution - is a number of samples per interval [0,1].
%
% One can also specify to do or not a weighted median filtering of scales h
%   in ICI rule. Here, the weighted median filtering is done only for final
%   scales.
%
% MCSimultions - is a number Monte-Carlo simulations. The erros are
%   accumulated and averaged. They are shown as
%
% WMedian - is a vector of weights for the weighted median filtering in the 
%           ICI procedure of the final scales, e.g. WMedian = [1 1 1 3 1 1 1];
% 
% >> Final Results of Monte-Carlo simulations:
%     'ISNR:    14.8161'
%     'SNR:     31.9985'
%     'PSNR:    34.2523'
%     'RMSE:    0.18267'
%     'MAE:     0.12875'
%     'MAX-DIF: 1.2291'
%
% Finaly, the results of denoising for every window and their fusing
%   estimate are shown. The optimal windows are shown in a saparated figure.
%   The errors shown in figures and for Monte-Carlo simulations can different
%   if MCSimultions>1 because figures show just the last simulation run.
% 
% V. Katkovnik,   12 August 2002
% Dmitriy Paliy 24 February 2004 (dmitriy.paliy@tut.fi)

clear all
tic
%--------------------------------------------------------------------------
% ICI settings
%--------------------------------------------------------------------------
GammaICI = 1.5; % Gamma parameter


%--------------------------------------------------------------------------
% MEDIAN WINDOW SIZES
%--------------------------------------------------------------------------
h = ceil([1 1.45.^(4:16)]);


%--------------------------------------------------------------------------
% SIGNAL settings
%--------------------------------------------------------------------------
Signal = 'StepWise2'; % A set available signals is: 'StepWise', 'StepWise1', 
                      % 'StepWise2', 'Blocks', 'Heavisine', 'Doppler',
                      % 'Bumps'.

Resolution = 1024; % number of samples


%--------------------------------------------------------------------------
% MEDIAN FILTERING OF FINAL SCALES
%--------------------------------------------------------------------------
WMedian = [1 1 1 1 1 1 1];


%--------------------------------------------------------------------------
% A Number of MONTE-CARLO Simultions
%--------------------------------------------------------------------------
MCSimultions = 1;

%--------------------------------------------------------------------------
% MODELLING
%--------------------------------------------------------------------------
deltaf  = Resolution-1;
delta   = 1/deltaf;
x       = (0:delta:1); % function arguments
[yN,xN] = size(x);

%--------------------------------------------------------------------------
% NOISE PARAMETERS
%--------------------------------------------------------------------------
y            = function_InputData1D(x,0.0,Signal); % TRUE signal. The NOISY 
            % signal is generated for each Monte-Carlo simulation (line 148)
            
% the noise is mixed
sigma_noise1 = 0.02;
sigma_noise2 = 0.2;
alpha        = 0.95;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
htimebar = timebar('Loop counter','Progress');
totalcounter = 2*length(x)*MCSimultions;

Final_MC_Errors = 0;

par = rem(h,2);
h(find(par==0)) = h(find(par==0))-1;

[N1,N2]=size(y);
itc = 0;
h1=ceil(h./2);

for mcarlo = 1:MCSimultions,    
            
    % noisy signal and its noise estimation
    z = function_InputData1D(x,[sigma_noise1 sigma_noise2],Signal,alpha);
    D2_Z = z(1,2:length(z))-z(1,1:length(z)-1); 
    sigma = median(abs(D2_Z(1:length(z)-1)))/(0.6745*sqrt(2));

    for s_x=1:length(z),
        itc = itc+1;
        timebar(htimebar,itc/totalcounter);
        
        % MEDIAN filtering for every scale and for every window function.
        % If number of samples is less than window length then only those
        % observations are taken into consideration.
        for s_h=1:length(h),           % estimates of Y as a matrix (N*N_h)
            %---------------------------------------------------
            % left window median
            %---------------------------------------------------
            l=[max(s_x-h(s_h)+1,1):s_x]; % sliding window
            stdh_left(s_h,s_x)=1/sqrt(2*length(l)/pi);
            yh_left(s_h,s_x)=median(z(l));

            %---------------------------------------------------
            % right window median
            %---------------------------------------------------
            l=[s_x:min(s_x+h(s_h)-1,length(z))]; % sliding window
            stdh_right(s_h,s_x)=1/sqrt(2*length(l)/pi);
            yh_right(s_h,s_x)=median(z(l));

            %---------------------------------------------------
            % symmetrical window median
            %---------------------------------------------------
            l=[max(s_x-h1(s_h)+1,1):min(s_x+h1(s_h)-1,length(z))]; % sliding window
            stdh_sym(s_h,s_x)=1/sqrt(2*length(l)/pi);
            yh_sym(s_h,s_x)=median(z(l));
        end;
    end;

    
    % the ICI rule for the LEFT window
    [yh_ici, h_opt, std_opt] = function_ICI_1D(yh_left,stdh_left,GammaICI,sigma,WMedian);
        
    % to recalculate optimal window length for every samples in order to
    % show them objectively. Remember that only a number of available
    % samples are taken into consideration if the length of window is
    % higher.
    h_opt = h(h_opt);
    tmph = [1:length(h_opt)]-h_opt+1; 
    tmph_indexes = find(tmph<=0);  
    tmph = [1:length(h_opt)];
    h_opt(tmph_indexes) = tmph(tmph_indexes);
        
    % the final estimate
    yh_WindowQ(1,:) = yh_ici;
    % the final windows
    h_opt_WindowQ(1,:) = h_opt;
    % the final estimate variances. They are used in fusing of
    % estimates.
    var_opt_WindowQ(1,:) = (std_opt.^2+eps);

    % right
    [yh_ici, h_opt, std_opt] = function_ICI_1D(yh_right,stdh_right,GammaICI,sigma,WMedian);
        
    h_opt = h(h_opt);
    tmph = [length(h_opt):-1:1]-h_opt+1;
    tmph_indexes = find(tmph<=0);
    tmph = [length(h_opt):-1:1];
    h_opt(tmph_indexes) = tmph(tmph_indexes);
      
    % the final estimate
    yh_WindowQ(2,:) = yh_ici;
    % the final windows
    h_opt_WindowQ(2,:)=h_opt;
    % the final estimate variances. They are used in fusing of
    % estimates.
    var_opt_WindowQ(2,:)=(std_opt.^2+eps);

    % symmetrical
    [yh_ici, h_opt, std_opt] = function_ICI_1D(yh_sym,stdh_sym,GammaICI,sigma,WMedian);
        
    h_opt = h(h_opt);
    tmph = [1:length(h_opt)] - ceil(h_opt./2);
    tmph_indexes = find(tmph<=0);
    tmph = [1:length(h_opt)]  + ceil(h_opt./2) - 1;
    h_opt(tmph_indexes) = tmph(tmph_indexes);

    tmph = [length(h_opt):-1:1] - ceil(h_opt./2);
    tmph_indexes = find(tmph<=0);  
    tmph = [length(h_opt):-1:1] + ceil(h_opt./2) - 1;
    h_opt(tmph_indexes) = tmph(tmph_indexes);
        
    % the final estimate
    yh_WindowQ(3,:) = yh_ici;   
    % the final windows
    h_opt_WindowQ(3,:) = h_opt;
    % the final estimate variances. They are used in fusing of
    % estimates.
    var_opt_WindowQ(3,:) = (std_opt.^2+eps);

    
    %%%%%%   FUSING    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BBETA = 30;
        
    for cv1=1:length(z),
        itc = itc+1;
        timebar(htimebar,itc/totalcounter);

        WW=kaiser(h_opt_WindowQ(1,cv1)*2-1,BBETA);  
        WL=WW(1:h_opt_WindowQ(1,cv1)-1); 

        WW=kaiser(h_opt_WindowQ(2,cv1)*2-1,BBETA); 
        WR=flipud(WW(1:h_opt_WindowQ(2,cv1)-1)); 

        WW=[WL' 1 WR'];
         
        yh_final_CV(cv1) = function_wmedian1D(WW,[z(cv1-h_opt_WindowQ(1,cv1)+1:cv1-1), z(cv1), z(cv1+1:cv1+h_opt_WindowQ(2,cv1)-1)]);
    end;
    
    %%%   ~ end of FUSING     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Final_MC_Errors = Final_MC_Errors + function_Errors(y,yh_final_CV,z)';
    
end;
%%%%%%%%%%%%%   END OF ALGORITHM   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

Final_MC_Errors = Final_MC_Errors./MCSimultions;

close(htimebar);

%--------------------------------------------------------------------------
% RESULTS
%--------------------------------------------------------------------------
version -release; % get matlab release
matlab_R=str2num(ans);

WindowType{1} = 'Median Left';
WindowType{2} = 'Median Right';
WindowType{3} = 'Median';

figure('name',['Results of Simulation: #',num2str(mcarlo)]),

subplot(3,2,1),
plot(y); 
grid on, axis tight, title('True Signal'),
if matlab_R>=14,
    ylabel('$y(x)$','interpreter','latex');
else
    ylabel('\ity(\itx)');
end;

subplot(3,2,2),
plot(z); 
grid on, axis tight, title('Noisy Signal'),
if matlab_R>=14,
    ylabel('$z(x)$','interpreter','latex');
else
    ylabel('\itz(\itx)');
end;

for i=1:length(WindowType)
    subplot(3,2,i+2),
    cur_im = yh_WindowQ(i,:);
    last_errors = function_Errors(y(:),cur_im(:),z(:));
    plot(cur_im); 
    
    grid on, axis tight,
    title([WindowType{i},' Est.: RMSE = ',num2str(last_errors(5)),', \Gamma = ',num2str(GammaICI)]),
    if matlab_R>=14,
        ylabel(['$\hat{y}_{',WindowType{i},'}(x)$'],'interpreter','latex');
    else
        ylabel(['\ity_{it{',WindowType{i},'}}(\itx)']);
    end;
end;

subplot(3,2,i+2), 
if matlab_R>=14,
    xlabel('$x$','interpreter','latex');
else
    xlabel('\itx');
end;

subplot(3,2,6), 
cur_im = yh_final_CV;
last_errors = function_Errors(y(:),cur_im(:),z(:));
plot(cur_im); 

grid on, axis tight,
title(['Final Fused Est.: RMSE = ',num2str(last_errors(5))]),
if matlab_R>=14,
    ylabel(['$\hat{y}_{Final}(x)$'],'interpreter','latex'),
    xlabel('$x$','interpreter','latex');
else
    ylabel(['\ity_{\it{Final}}(\itx)']),
    xlabel('\itx');
end;


figure('name',['Scales: Simulation #',num2str(mcarlo)]),

for i=1:length(WindowType)
    subplot(1,3,i),
    cur_im = h_opt_WindowQ(i,:);
    plot(cur_im);
    
    grid on, axis tight square,
    title([WindowType{i},', \Gamma = ',num2str(GammaICI)]),    
    if matlab_R>=14,
        xlabel('$x$','interpreter','latex');
    else
        xlabel('\itx');
    end;
end;
subplot(1,3,1), 
if matlab_R>=14,
    ylabel(['$h(x)$'],'interpreter','latex'),
else
    ylabel(['\ith(\itx)']),
end;

disp('Final Results of Monte-Carlo simulations:')
d{1} = ['ISNR:    ', num2str(Final_MC_Errors(1))];
d{2} = ['SNR:     ', num2str(Final_MC_Errors(2))];
d{3} = ['PSNR:    ', num2str(Final_MC_Errors(3))];
d{4} = ['MSE:     ', num2str(Final_MC_Errors(4))];
d{5} = ['RMSE:    ', num2str(Final_MC_Errors(5))];
d{6} = ['MAE:     ', num2str(Final_MC_Errors(6))];
d{7} = ['MAX-DIF: ', num2str(Final_MC_Errors(7))];
disp(d')
toc/60