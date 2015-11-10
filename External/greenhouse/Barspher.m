function [Barspher] = Barspher(X,alpha)
% Bartlett's sphericity test.
%[Basically, here we are testing the null hypothesis that the R correlations' matrix
%is equal to its I identity matrix (determinant of R equals to one) or that the 
%intercorrelation matrix comes from a population in which the variables are noncollinear.
%It would means that all the p-axis have the same variability or eigenvalues (l);
%recall that det(R)=prod(diag(L))=Wilk's lambda].
%
%     Syntax: function [Barspher] = Barspher(X,alpha) 
%      
%     Inputs:
%          X - multivariate data matrix. 
%      alpha - significance level (default = 0.05). 
%     Output:
%          n - sample-size.
%          p - variables.
%         X2 - observed chi-square statistic used to test any deviation from
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
%                Barspher(X)
%
%             Answer is:
%   ------------------------------
%    Component         Eigenvalue
%   ------------------------------
%        1               2.9398
%        2               0.0343
%        3               0.0259
%   ------------------------------
%
%   ---------------------------------------------
%    Sample-size    Variables        X2       P
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
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). Barspher: Bartlett's sphericity tests. 
%    A MATLAB file. [WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
%    loadFile.do?objectId=3694&objectType=FILE
%
%  References:
% 
%  Green, P. E. (1978), Analyzing Multivariate Data. Illinois:The Dryden Press. pp. 361-362. 
%  Johnson, R. A. and Wichern, D. W. (1992), Applied Multivariate Statistical Analysis.
%              3rd. ed. New-Jersey:Prentice Hall. pp. 158-160.
%
  
if nargin < 2, 
   alpha = 0.05;  %(default)
end; 

if nargin < 1, 
   error('Requires at least one input arguments.');
end;

[n p] = size(X);
R = corrcoef(X);  %correlations' matrix
X2 = -1*[(n-1)-(1/6)*((2*p)+5)]*log(det(R));  %approximation to chi-square statistic
v = (1/2)*(p^2-p);  %degrees of freeedom
df = v;
P = 1-chi2cdf(X2,v);  %Probability that null Ho: is true.

E=flipud(sort(eig(R)));

fprintf('------------------------------\n');
disp(' Component         Eigenvalue')
fprintf('------------------------------\n');
for i=1:p
   fprintf('     %d               %.4f\n',i,E(i))
end
fprintf('------------------------------\n');
disp(' ')

fprintf('-----------------------------------------------------\n');
disp(' Sample-size    Variables        X2        df     P')
fprintf('-----------------------------------------------------\n');
fprintf('%8.i%13.i%16.4f%8i%8.4f\n',n,p,X2,df,P);
fprintf('-----------------------------------------------------\n');
fprintf('With a given significance level of: %.2f\n', alpha);
     
if P >= alpha;
   fprintf('Assumption of sphericity is tenable.\n\n');
else
   fprintf('Assumption of sphericity is not tenable.\n\n');
end;
