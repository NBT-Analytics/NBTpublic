function [sphertest] = sphertest(X,alpha)
%SPHERTEST gives several sphericity tests as Bartlett and Mauchly to choose from 
%any of the following functions: Barspher and Mauspher.
%
%Sphericity test's menu.
%
%   Syntax: function [sphertest] = sphertest(X,alpha)) 
%      
%     Inputs:
%          X - multivariate data matrix. 
%      alpha - significance level (default = 0.05). 
%     Output:
%          n - sample-size.
%          p - variables.
%          - observed statistic used to test any deviation from
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
%                sphertest(X)
%
%       Answer is:
%
%             Answer is:
%   Sphericity tests menu:
%   1) Bartlett
%   2) Mauchly
%   Which test do you want?: 1
% 
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
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). Sphertest: Sphericity tests menu. 
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
    alpha = 0.05; 
end 

if nargin < 2, 
   alpha = 0.05;  %(default)
end; 

if nargin < 1, 
   error('Requires at least one input arguments.');
end;

disp('Sphericity tests menu:')
disp('1) Bartlett')
disp('2) Mauchly')
option=input('Which test do you want?: ');
disp(' ')
switch  option
case 1,
   %option1: Bartlett's test
   Barspher(X,alpha);
case 2,
   %option2: Mauchly's test
   Mauspher(X,alpha);
end;

