
function cur_im = demo_LPAICI_1D(y, m ,h)

if nargin < 1, y = []; end
if nargin < 2, m = []; end
if nargin < 3, h = []; end
   

% Demonstration of the LPA-ICI denoising of a 1D signal.
% 
% The algorithm searches for the largest local vicinity of the point of estimation 
% where the LPA assumptions fit well to the data. The estimates are calculated for 
% a few scales and compared. The adaptive scale is defined as the largest of those 
% for which the estimate does not differ significantly from the estimates corresponding 
% to the smaller scales.
%
% Firstly, the LPA settings should be specified:
%
%   m - is an order of LPA.
%
%   WindowTypeCell - CELL array of window function types, can be : 
%               'Gaussian' (default), 'GaussianLeft', 'GaussianRight',
%               'Rectangular', 'RectangularLeft', 'RectangularRight',
%               'Treecube', 'Hermitian', 
%               'Exponential', 'ExponentialLeft', 'ExponentialRight',
%               'InterpolationWindow1', 'InterpolationWindow2', 'InterpolationWindow3'
%
%   e.g. WindowTypeCell{1} = 'Gaussian';
%        WindowTypeCell{2} = 'GaussianLeft';
%        WindowTypeCell{3} = 'GaussianRight';
%   the final estimate will consist of these 3 estimates: left, right, and
%   symmetrical.
%
%   h - is a set of scales. It is worth to remeber that scale h has
%   different meanings for different types of window functions. E.g., for
%   the symmetrical Rectangular window h is a length of window and equal to
%   support of the window. This value should be odd, if it is even then h
%   forces to be h+1. For the Gaussian window h is a length of support and
%   h/9 is a variance parameter of Gaussian function.
%
% Secondly, a set of Gamma parameters should be specified for the ICI
%   rule in GammaICI=[0.5:0.1:3.0], e.g. An optimal Gamma parameter is chosen 
%   by the Cross-Validation rule for every type of window function 
%   (WindowTypeCell). One can specify GammaICI as a single parameter and obtain
%   results of the LPA-ICI with a fixed Gamma (GammaICI=1.5 e.g).
%
% A set available signals is: 'StepWise', 'StepWise1', 'StepWise2', 
%   'Blocks', 'Heavisine', 'Doppler', 'Bumps'.
% 
% One can specify a level of noise in 'sigma_noise'. For more details of
%   noise model please read in function_InputData.
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
% Alessandro Foi 15 november 2003
% Dmitriy Paliy 24 February 2004 (dmitriy.paliy@tut.fi)

%clear all

%--------------------------------------------------------------------------
% ICI settings
%--------------------------------------------------------------------------
GammaICI = [0.5:0.1:3.0]; % set of Gamma parameters


%--------------------------------------------------------------------------
% LPA settings
%--------------------------------------------------------------------------
if isempty(m),
m = 2; % order of polynomial approximation
end

if isempty(h),
h = ceil([1 1.45.^(4:16)]); % set of scales
end

% window functions used in LPA (as many estimates as many window functions 
% is given)
WindowTypeCell{1} = 'Gaussian';
WindowTypeCell{2} = 'GaussianLeft';
WindowTypeCell{3} = 'GaussianRight';


%--------------------------------------------------------------------------
% SIGNAL settings
%--------------------------------------------------------------------------
Signal = 'Heavisine'; % A set available signals is: 'StepWise', 'StepWise1', 
                      % 'StepWise2', 'Blocks', 'Heavisine', 'Doppler', 'Bumps'.





%--------------------------------------------------------------------------
% MEDIAN FILTERING
%--------------------------------------------------------------------------
WMedian = [1 1 1 3 1 1 1];


%--------------------------------------------------------------------------
% A Number of MONTE-CARLO Simultions
%--------------------------------------------------------------------------
MCSimultions = 1;

%--------------------------------------------------------------------------
% NOISE PARAMETERS
%--------------------------------------------------------------------------
sigma_noise = 1;
alpha       = 1;

if isempty(y),
y           = function_InputData1D(x,0.0,Signal); % TRUE signal. The NOISY 
            % signal is generated for each Monte-Carlo simulation (line 176)
end
Resolution = numel(y); % number of samples

%--------------------------------------------------------------------------
% MODELLING
%--------------------------------------------------------------------------
deltaf  = Resolution-1;
delta   = 1/deltaf;
x       = (0:delta:1);
[yN,xN] = size(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------
% KERNELS construction
%---------------------------------------------------------
htimebar = timebar('Loop counter','Progress');
totalcounter = length(GammaICI)*MCSimultions+1;
timebar(htimebar,1/totalcounter);
disp('Creation LPA kernels ...');
[kernels] = function_CreateLPAKernels1D(m,h,WindowTypeCell);

% you can uncomment the next line to draw kernels:
% utility_DrawLPAKernels;

Icv_CRITERIA = zeros([length(WindowTypeCell),length(GammaICI)]);
RMSE_Error = zeros([length(WindowTypeCell),length(GammaICI)]);
Final_MC_Errors = 0;



itc = 1;
disp('LPA-ICI ...');
for mcarlo = 1:MCSimultions,    
    
    % noisy signal and its noise estimation
    %z = function_InputData1D(x,sigma_noise,Signal);
    z = y;
    D2_Z = z(1,2:length(z))-z(1,1:length(z)-1); 
    sigma = median(abs(D2_Z(1:length(z)-1)))/(0.6745*sqrt(2));

    % to do LPA for every scale and for every window function
    for s2=1:length(h),
        for s1=1:length(WindowTypeCell),
    
            % the kernel
            gh = kernels{s1,s2}';
            % the estimate
            yh{s1}(s2,1:xN)= convn(z,gh,'same')';
            % standard deviation of estimate
            stdh(s1,s2)=sqrt(sum(sum(gh.^2)));
                
            % g(0) used in Cross-Validation criterion
            gh0{s1}(s2) = gh(ceil(size(gh,2)/2));
        
        end;
    end;

    % run Cross-Validation criterion for selection Gamma parameters
    for i=1:length(GammaICI),
        
        itc = itc+1;
        timebar(htimebar,itc/totalcounter);
        
    
        yh_final=0; var_inv=0;
        
        %%%% ICI for function estimation optimal window size selection %%%%%
        for s1=1:length(WindowTypeCell)
        
            % the ICI rule selects from a set of estimates only one
            % estimate. It is done for different types of windows.
            [yh_ici,h_opt,std_opt] = function_ICI_1D(yh{s1},stdh(s1,:),GammaICI(i),sigma,WMedian);
            
            % the final estimate
            yh_Q_CV{s1,i}      = yh_ici;
            % the final estimate variances. They are used in fusing of
            % estimates.
            var_opt_Q_CV{s1,i} = (std_opt.^2+eps);
            % optimal windows
            h_opt_Q_CV{s1,i}   = h_opt;

            gh0_opt(s1,1:length(x)) = gh0{s1}(h_opt);

            % rmse
            RMSE_Error(s1,i) = RMSE_Error(s1,i) + sqrt(sum((y(:) - yh_ici(:)).^2)/length(y(:)));
            

            % Cross-Vlidation criterion
            tmpCV = z - yh_Q_CV{s1,i};
            tmpGH = 1 - gh0_opt(s1,:);
            tmpCV_index = find(gh0_opt(s1,:)~=1);
            tmpCV(tmpCV_index) = tmpCV(tmpCV_index)./tmpGH(tmpCV_index);
            Icv(s1,i) = sum(tmpCV(tmpCV_index).^2);
            Icv(s1,i) = Icv(s1,i)/length(z);
            
            Icv_CRITERIA(s1,i) = Icv_CRITERIA(s1,i) + Icv(s1,i);
                        
        end %% for s1, directions            
    end;
    %%%%%%%%%%%%%   END OF ALGORITHM   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    

    %%%%%%%%%%% Cross-Validation Results %%%%%%%%%%%%%%%%
    yh_final_CV=0; var_inv_CV=0;
    for ss1=1:length(WindowTypeCell)
        %%%%%%%%%%%%%%%%%%%%%% FUSING AFTER CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        
        [a(ss1)] = min(find( Icv(ss1,:) == min(Icv(ss1,:)) ));
                
        %%%%%%   FUSING    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        yh_final_CV = yh_final_CV + yh_Q_CV{ss1,a(ss1)}./var_opt_Q_CV{ss1,a(ss1)}; 
        var_inv_CV = var_inv_CV + 1./var_opt_Q_CV{ss1,a(ss1)}; 
            
        h_opt_Q_fcv{ss1} = h_opt_Q_CV{ss1,a(ss1)};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end;

    yh_final_CV = yh_final_CV./var_inv_CV;

    Final_MC_Errors = Final_MC_Errors + function_Errors(y,yh_final_CV,z)';
    
end; %~end of monte carlo

Final_MC_Errors = Final_MC_Errors./MCSimultions;

close(htimebar)

%--------------------------------------------------------------------------
% RESULTS
%--------------------------------------------------------------------------
version -release; % get matlab release
matlab_R=str2num(ans);

figure('name',['Results of Simulation: #',num2str(mcarlo)]),

for i=1:length(WindowTypeCell)
    subplot(2,2,i),
    cur_im = yh_Q_CV{i,a(i)};
    last_errors = function_Errors(y(:),cur_im(:),z(:));
    plot(x, cur_im); 
    
    grid on, axis tight,
    title([WindowTypeCell{i},' Est.: RMSE = ',num2str(last_errors(5)),', \Gamma = ',num2str(GammaICI(a(i)))]),
    if matlab_R>=14,
        ylabel(['$\hat{y}_{',WindowTypeCell{i},'}(x)$'],'interpreter','latex'),
        xlabel('$x$','interpreter','latex');
    else
        ylabel(['\ity_{\it{',WindowTypeCell{i},'}}(\itx)']),
        xlabel('\itx');
    end;
end;

subplot(2,2,4), 
cur_im = yh_final_CV;
last_errors = function_Errors(y(:),cur_im(:),z(:));
plot(x, cur_im); 

grid on, axis tight,
title(['Fused Final Est.: RMSE = ',num2str(last_errors(5))]),
if matlab_R>=14,
    ylabel(['$\hat{y}_{Final}(x)$'],'interpreter','latex'),
    xlabel('$x$','interpreter','latex');
else
    ylabel(['\ity_{\it{Final}}(\itx)']),
    xlabel('\itx');
end;


figure('name',['Windows of Simulation: #',num2str(mcarlo)]),

for i=1:length(WindowTypeCell)
    subplot(3,1,i),
    cur_im = h_opt_Q_CV{i,a(i)};
    plot(x, h(cur_im).*delta);
    
    grid on, axis tight,
    title(['Scales for ',WindowTypeCell{i},' window function, \Gamma = ',num2str(GammaICI(a(i)))]),
    if matlab_R>=14,
        ylabel(['$h_{',WindowTypeCell{i},'}(x)$'],'interpreter','latex');
    else
        ylabel(['\ith_{\it{',WindowTypeCell{i},'}}(\itx)']);
    end;
end;
if matlab_R>=14,
    xlabel('$x$','interpreter','latex');
else
    xlabel('\itx');
end;


if length(GammaICI)>1,
    Icv_CRITERIA = Icv_CRITERIA./MCSimultions;
    RMSE_Error = RMSE_Error./MCSimultions;

    figure('name','Cross-Validaion & RMSE criteria'),
        
    for i=1:length(WindowTypeCell)
        subplot(1,3,i),
        plot(GammaICI, Icv_CRITERIA(i,:), 'r--', 'LineWidth', 2); hold on,
        plot(GammaICI, RMSE_Error(i,:), 'LineWidth', 2),
        if matlab_R>=14,
            xlabel('$\Gamma$','interpreter','latex');
        else
            xlabel('\it\Gamma');
        end;
        grid on, axis tight square, title([WindowTypeCell{i},' window']);
    end;
    subplot(1,3,1), 
    if matlab_R>=14,
        ylabel('$CV(\Gamma), RMSE(\Gamma)$','interpreter','latex');
    else
        ylabel('CV(\it\Gamma), RMSE(\it\Gamma)');
    end;
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