function [Mauspher] = Mauspher(X,alpha)
%Mauchly's sphericity test.
%[Basically, here we are testing the null hypothesis that for all p single components the
%variances are equal and all covariances are zero. It would means that all the p-axis have
%the same variability or eigenvalues (l);recall that det(R)=prod(diag(L))=Wilk's lambda].
%
%     Syntax: function [Mauspher] = Mauspher(X,alpha) 
%      
%     Inputs:
%          X - multivariate data matrix. 
%      alpha - significance level (default = 0.05). 
%     Output:
%          n - sample-size.
%          p - variables.
%          L - Mauchly's statistic used to test any deviation from
%              an expected sphericity.
%          P - probability that null Ho: is true.
%
%    Example: From the data of Joliceaur and Mossiman (1960) given by Johnson and Wichern
%             (1992, p. 275), for the female cases (n = 24) and three variables (p = 3). We 
%             are interested to test the sphericity of its axes with a significance level = 0.05.
%                     ---------------    ---------------
%                      x1    x2    x3     x1    x2    x3
%                     ---------------    ---------------
%                      98    81    38    138    98    51
%                     103    84    38    138    99    51
%                     103    86    42    141   105    53
%                     105    86    42    147   108    57
%                     109    88    44    149   107    55
%                     123    92    50    153   107    56
%                     123    95    46    155   115    63
%                     133    99    51    155   117    60
%                     133   102    51    158   115    62
%                     133   102    51    159   118    63
%                     134   100    48    162   124    61
%                     136   102    49    177   132    67
%                     ---------------    ---------------
%
%             Total data matrix must be:
%              X=[98 81 38;103 84 38;103 86 42;105 86 42;109 88 44;123 92 50;123 95 46;
%              133 99 51;133 102 51;133 102 51;134 100 48;136 102 49;138 98 51;138 99 51;
%              141 105 53;147 108 57;149 107 55;153 107 56;155 115 63;155 117 60;158 115 62;
%              159 118 63;162 124 61;177 132 67];
%
%             Calling on Matlab the function: 
%                Mauspher(X)
%
%             Answer is:
%   ----------------------------------
%    Component             Eigenvalue
%   ----------------------------------
%        1                  678.3657
%        2                    6.7697
%        3                    2.8538
%   ----------------------------------
%
%   ---------------------------------------------
%    Sample-size    Variables        L        P
%   ---------------------------------------------
%         24            3        125.9015  0.0000
%   ---------------------------------------------
%   With a given significance level of: 0.05
%   Assumption of sphericity is not tenable.
%

%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%
%  July 6, 2003. 
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). Mauspher: Mauchly's sphericity tests. 
%    A MATLAB file. [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%    loadFile.do?objectId=3694&objectType=FILE
%
%  References:
%
%  Davies, A. W. (1971), Percentile approximations for a class of likelihood ratio
%              criteria. Biometrika, 58:349-356.
%  Johnson, R. A. and Wichern, D. W. (1992), Applied Multivariate Statistical Analysis.
%              3rd. ed. New-Jersey:Prentice Hall. pp. 158-160.
%  Mauchly, J. W. (1940), Significance test for sphericity of a normal n-variate
%              distribution. The Annals of Mathematical Statistics, 11:204-209.
%
  
if nargin < 2, 
   alpha = 0.05;  %(default)
end; 

if nargin < 1, 
   error('Requires at least one input arguments.');
end;

[n p] = size(X);
S = cov(X);  %covariances' matrix
W = (n-1)*S;
L = det(W)/((1/p)*trace(W))^p;  %Mauchly's statistic 
M = (n-1)-(2*p*p+p+2)/6/p;
LL = (-1)*M*log(L);  %Chi-square approximation                                          
A = (p+1)*(p-1)*(p+2)*(2*p*p*p+6*p*p+3*p+2)/288/p/p;
F = p*(p+1)/2-1;  %degrees of freedom
A1 = 1-chi2cdf(LL,F);
A3 = 1-chi2cdf(LL,F+4);
P = A1+(A/M/M)*(A3-A1);  %Probability that null Ho: is true.

E=flipud(sort(eig(S)));

fprintf('----------------------------------\n');
disp(' Component             Eigenvalue')
fprintf('----------------------------------\n');
for i=1:p
   fprintf('     %d               %11.4f\n',i,E(i))
end
fprintf('----------------------------------\n');
disp(' ')

fprintf('---------------------------------------------\n');
disp(' Sample-size    Variables        L        P')
fprintf('---------------------------------------------\n');
fprintf('%8.i%13.i%16.4f%8.4f\n',n,p,L,P);
fprintf('---------------------------------------------\n');
fprintf('With a given significance level of: %.2f\n', alpha);
     
if P >= alpha;
   fprintf('Assumption of sphericity is tenable.\n\n');
else
   fprintf('Assumption of sphericity is not tenable.\n\n');
end;
