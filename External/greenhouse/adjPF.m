function p = adjPF(X,F)
%ADJPF Adjustment of the F statistic by Epsilon on Repeated Measures ANOVA.
% Sphericity is an assumption of repeated measure ANOVA. It means that the 
% variance-covariance structure of the repeated measure ANOVA follows a certain
% pattern. Sphericity is, in a nutshell, that the variances of the differences
% between the repeated measurements should be about the same. Violations of the
% sphericity assumption lead to biased P-values. The alpha error of a test may
% be set at 5%, but the test may be actually rejecting the null hypothesis 10%
% of the time. This raises doubts of the conclusions of the repeated measure
% ANOVA. 
% In repeated measure experiments the same subjects are tested multiple times
% under different conditions. It is a good idea to check if the responses made
% under some conditions are correlated more closely than responses made under
% other conditions.
% Box (1954) showed that if the sphericity assumption is not met, then the F 
% ratio is positively biased (we are rejecting felasely too often). According
% to Greenhouse and Geisser (1959), the extent to which the covariance matrix
% deviates from sphericity is reflected in a parameter called epsilon. Epsilon
% is then used to adjust for the potential bias in the F statistic.
% To adjust for the positive bias it is suggested altering the degrees of freedom
% of the F-statistic. Both adjustements estimate epsilon and then multiply the
% numerator and denominator degrees of freedom by this estimate before determining
% significance levels for the F-tests. Significance levels associated with the
% adjusted tests are labeled adjP > F on the output.
%
% Syntax: function adjPF(X,F)
%
% Inputs:
%    X - Input matrix can be a data matrix (size n-data x k-treatments)
%    F - Observed (calculated) F statistic value
% The adjustment of the F statistic can be by Epsilon menu for:
% 1) Greenhouse-Geisser
% 2) Huynh-Feldt
% 3) Box's conservative
%
% Output:
%    p - adjusted P-value.
%
% Example 2 of Maxwell and Delaney (p.497). This is a repeated measures example
% with two within and a subject effect. We have one dependent variable:reaction
% time, two independent variables: visual stimuli are tilted at 0, 4, and 8 
% degrees; with noise absent or present. Each subject responded to 3 tilt and 2
% noise given 6 trials. Data are,
%
%                      0           4           8                  
%                 -----------------------------------
%        Subject    A     P     A     P     A     P
%        --------------------------------------------
%           1      420   480   420   600   480   780
%           2      420   360   480   480   480   600
%           3      480   660   480   780   540   780
%           4      420   480   540   780   540   900
%           5      540   480   660   660   540   720
%           6      360   360   420   480   360   540
%           7      480   540   480   720   600   840
%           8      480   540   600   720   660   900
%           9      540   480   600   720   540   780
%          10      480   540   420   660   540   780
%        --------------------------------------------
%
% The three measurements of reaction time were averaging across noise 
% ausent/present. Given,
%
%                         Tilt
%                  -----------------
%        Subject     0     4     8    
%        ---------------------------
%           1       450   510   630
%           2       390   480   540
%           3       570   630   660
%           4       450   660   720
%           5       510   660   630
%           6       360   450   450
%           7       510   600   720
%           8       510   660   780
%           9       510   660   660
%          10       510   540   660
%        ---------------------------
%
% The F statistic for the runned RMANOVA is 40.719.
%
% We need to estimate the P-value associated with the adjusted F with the 
% Huynh-Feldt epsilon.
%
% Data matrix must be:
%      X=[450 510 630;390 480 540;570 630 660;450 660 720;510 660 630;
%      360 450 450;510 600 720;510 660 780;510 660 660;510 540 660];
% 
%      F=40.719
%
% Calling on Matlab the function: 
%    p = adjPF(X,F)
%
% Answer is:
%
% Adjustment of the F statistic by Epsilon menu:
% 1) Greenhouse-Geisser
% 2) Huynh-Feldt
% 3) Box's conservative
%
% Which adjustment do you want?: 2
% 
% p = 1.3166e-008
%
% Created by A. Trujillo-Ortiz, R. Hernandez-Walls, A. Castro-Perez
%            and K. Barba-Rojo
%            Facultad de Ciencias Marinas
%            Universidad Autonoma de Baja California
%            Apdo. Postal 453
%            Ensenada, Baja California
%            Mexico.
%            atrujo@uabc.mx
%
% Copyright. November 02, 2006.
%
% --Special thanks are given to S�ren Andersen, Universit�t Leipzig, Institut
%   Psychologie I, Professur Allgemeine Psychologie & Methodenlehre, Seeburgstr
%   14-20, D-04103 Leipzig, Deutchland, for encouraging us to create this m-file-- 
%
% To cite this file, this would be an appropriate format:
% Trujillo-Ortiz, A., R. Hernandez-Walls, A. Castro-Perez and K. Barba-Rojo. (2006).
%   adjPF:Adjustment of the F statistic by Epsilon on Repeated Measures. A MATLAB file.
%   [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%   loadFile.do?objectId=12871
%
% References:
% Box, G.E.P. (1954), Some theorems on quadratic forms applied in the study
%     of analysis of variance problems: II. Effect of inequality of variance
%     and of correlation between errors in the two-way classification. Annals
%     of Mathematical Statistics, 25:484-498.
% Greenhouse, S.W. and Geisser, S. (1959), On methods in the analysis of
%     profile data. Psychometrika, 24:95-112. 
% Maxwell, S.E. and Delaney, H.D. (1990), Designing Experiments and Analyzing
%     Data: A model comparison perspective. Pacific Grove, CA: Brooks/Cole.
% 

if nargin < 2,
    error('Requires two input arguments.');
end

[errorcode X F] = distchck(2,X,F);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

[n k] = size(X);

%disp(' ')
%disp('Adjustment of the F statistic by Epsilon menu:')
%disp('1) Greenhouse-Geisser')
%disp('2) Huynh-Feldt')
%disp('3) Box''s conservative')
%disp(' ')
%option = input('Which adjustment do you want?: ');
option =1; % see Atkinson 2001 (if epsilon below 0.75 use GG else use HF..

disp('GG epsilon:')
disp(epsGG(X))
x = epsGG(X);
if(x > 0.75)
    option=2;
    disp('HF used')
else 
    option =1;
    disp('GG used')
end

switch  option
    case 1,
        %option1: Greenhouse-Geisser epsilon adjustment
        x = epsGG(X) ; %call to the m-file Greenhouse-Geisser epsilon
        v1 = x*(k-1);  %adjusted numerator degrees of freedom
        v2 = x*(k-1)*(n-1);  %adjusted denominator degrees of freedom
        p = 1 - fcdf(F,v1,v2);
        p = p(1,1);
    case 2,
        %option2: Huynh-Feldt epsilon adjustment
        x = epsHF(X); %call to the m-file Huynh-Feldt epsilon
        v1 = x*(k-1);  %adjusted numerator degrees of freedom
        v2 = x*(k-1)*(n-1);  %adjusted denominator degrees of freedom
        p = 1 - fcdf(F,v1,v2);
        p = p(1,1);
    case 3,
        %option3: Box's conservative epsilon adjustment
        x = epsB(X); %call to the m-file Box's conservative epsilon
        v1 = x*(k-1);  %adjusted numerator degrees of freedom
        v2 = x*(k-1)*(n-1);  %adjusted denominator degrees of freedom
        p = 1 - fcdf(F,v1,v2);
        p = p(1,1);
end;

return,