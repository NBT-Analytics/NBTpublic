function [error_criteria,Error_labels]=function_Errors(X,Xest,Y,displabels)
% computes error criteria   (function_Errors)
%
% inputs are:
% Original Image , Estimate, Noisy(*), display_labels(*)
%
% output is a column vector with the following criteria:
%
% ISNR(*) Improvement in Signal-to-Noise Ratio
% SNR     Signal-to-Noise Ratio
% PSNR    Peak Signal-to-Noise Ratio
% MSE     Mean Squared Error          (l-2 norm squared)
% RMSE    Root of Mean Squared Error  (l-2 norm)
% MAE     Mean Absolute Error         (l-1 norm)
% MAX     Maximum Absolute Difference (l-infinity norm)
%
%
% display_labels  defines output to screen of result labels:
%                 1   standard labels (i.e. acronyms)
%                 2  "verbose" labels
%
% (*) indicates optional inputs
%
% An optional second output can be given in order to extract a column vector with string labels:
%   ['ISNR: ';'SNR:  '; 'PSNR: '; 'MSE:  '; 'RMSE: '; 'MAE:  '; 'MAX:  '];
%
%
% NOTE (for 2D images only):
%       If the original image has maximum <2, then it is assumed that
%       signals are considered on the range [0 1] and hence they are
%       multiplied by 255 in order to scale them to the range [0 255].
%       In this way the calculated MSE, RMSE, MAE, and MAX values
%       agree with the normalization most commonly found in the
%       literature.
%       1D signals are never re-normalized.
%
%
% Alessandro Foi - Tampere University of Technology - September 2005

if ~((nargin==2)|((nargin==3)&(numel(Y)==1)))
    ISNR_on=1;
    if (numel(X)~=numel(Xest))|(numel(X)~=numel(Y))
        disp('  ')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        disp('  INPUT SIGNALS MUST HAVE SAME NUMBER OF ELEMENTS  ')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        return
    end
else
    ISNR_on=0;
    if nargin==3
        displabels=Y;
    end
    if numel(X)~=numel(Xest)
        disp('  ')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        disp('  INPUT SIGNALS MUST HAVE SAME NUMBER OF ELEMENTS  ')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        return
    end

end

maxl2=max(X(:));

if ~(size(X,1)==1|size(X,2)==1)  % if 1D signal, don't renormalize signal
    if maxl2 >= 2
        maxl2=255;
    else
        maxl2=255;
        X=255*X;
        Xest=255*Xest;
        if ISNR_on==1
            Y=255*Y;
        end
    end
end;
SNR=10*log10(sum(abs(X(:).*X(:)))/sum(abs(Xest(:)-X(:)).^2));
mae_noisy=mean(abs(Xest(:)-X(:)));
mse_noisy=mean((Xest(:)-X(:)).^2);
rmse_noisy=sqrt(mse_noisy);
psnr_noisy=20*log10(maxl2/rmse_noisy);
maxdif=max(abs(Xest(:)-X(:)));
error_criteria=[SNR ; psnr_noisy; mse_noisy; rmse_noisy; mae_noisy; maxdif];
Error_labels = ['SNR:  '; 'PSNR: '; 'MSE:  '; 'RMSE: '; 'MAE:  '; 'MAX:  '];
Error_verbose= ['SNR  Signal-to-Noise Ratio                           : ';'PSNR Peak Signal-to-Noise Ratio                      : ';'MSE  Mean Squared Error          (l-2 norm squared)  : ';'RMSE Root of Mean Squared Error  (l-2 norm)          : ';'MAE  Mean Absolute Error         (l-1 norm)          : ';'MAX  Maximum Absolute Difference (l-infinity norm)   : '];
if ISNR_on==1
    ISNR = 10*log10(sum(abs(X(:)-Y(:)).^2)/sum(abs(Xest(:)-X(:)).^2));
    error_criteria=[ISNR; error_criteria];
    Error_labels = ['ISNR: '; Error_labels];
    Error_verbose= ['ISNR Improvement in Signal-to-Noise Ratio            : '; Error_verbose];
end

if (nargin==4)|((nargin==3)&(ISNR_on==0))
    if displabels==1
        disp(' ');
        for iiii = 1:numel(error_criteria),
            disp([Error_labels(iiii,:) num2str(error_criteria(iiii))]);
        end
    elseif displabels==2
        disp(' ');
        for iiii = 1:numel(error_criteria)
            disp([Error_verbose(iiii,:) num2str(error_criteria(iiii))]);
        end
    elseif displabels==0
    else
        disp('  ')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        disp('function_Errors:  displabels must be either 0, 1 or 2')
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    end
end

