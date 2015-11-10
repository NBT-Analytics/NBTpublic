function[p]=nbt_perm_group_diff(varargin)

%Usage:  perm_corr(x,y,type,n,plotting)

% Input:
% x=vector
% y=vector;
% type is 'mean' or 'median'.
% n = number of permutations (1000 = default)
% plotting =1 or 0, if plotting is 1 then the histogram of the
% null-distribution is plotted (0 = default)

% Output: P-value based on permutation test

% Function: computes P-value for difference in mean or median between x and
% y

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2010  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.


%% assigning
x=varargin{1};
y=varargin{2};

if length(varargin)<3 || isempty(varargin{3})
    type='mean';
else
    type=varargin{3};
end
if length(varargin)<4  || isempty(varargin{4})
    n=1000;
else
    n=varargin{4};
end
if length(varargin)<5  || isempty(varargin{5})
    plotting=0;
else
    plotting=varargin{5};
end

[rows, columns]=size(x);
if columns>rows
    x=x';
    y=y';
end

%% remove Nan

x=x(~isnan(x));
y=y(~isnan(y));

%% permutation

if strcmp(type,'mean')
    diff=mean(x)-mean(y);
else
    diff=median(x)-median(y);
end

diff_perm=zeros(1,n);
pooled=[x;y];
L=length(pooled);
Lx=length(x);
Ly=length(y);

for i=1:n
    perm=pooled(randperm(L));
    x_perm=perm(1:Lx);
    y_perm=perm(Lx+1:end);
    if strcmp(type,'mean')
        perm_diff(i)=mean(x_perm)-mean(y_perm);
    else
        perm_diff(i)=median(x_perm)-median(y_perm);
    end
end

if diff>0
    p=numel(find(perm_diff>diff)+1)/(n+1);
else
    p=numel(find(perm_diff<diff)+1)/(n+1);
end

%% plotting
figure(1)
if plotting
    hist(perm_diff,50);
    y=ylim;
    h(1)=line([diff diff],[y(1) y(2)],'color','red');
    hold on
    h(2)=plot(1,'visible','off');
    hold off
    
    legendtext{1}='observed difference';
    legendtext{2}='Null distribution';
    title(['P = ',num2str(p)])
    legend(h,legendtext)
end


