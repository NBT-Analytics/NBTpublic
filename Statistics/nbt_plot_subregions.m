function[integrated_regions]= nbt_plot_subregions(varargin)


% plot_subregions(data,plotting,cmin,cmax)
% data=1 by 6 vector
% plotting =1 or 0
% cmin= double
% cmax=double

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if(isempty(varargin{5}))
ind{1}=[128,32,25,21,26,27,23,19,18,16,15,126,127,14,10,4,8,2,3,123,1,125,9,17,124,122,24,33,22];
ind{2}=[48 43 38 49 44 39 34 28 40 35 56 50 46 51 47 41 45 57];
ind{3}=[42 29 20 12 5 118 11 93 54 37 30 13 6 112 105 87 79 31 7 106 80 55 36 104 111];
ind{4}=[117 110  103 98 116 109 102 97 108 115 121 114 100 107 113 120 119 101];
ind{5}=[63 68 64 58 65 59 66 52 60 67 72 53 61 62 78 86 77 85 92 84 91 90 96 95 94 99];
ind{6}=[71  76 70 75 83 69 74 82 89 73 81 88];
% else
% ind = varargin{5};
% end


load('nbt_CoolWarm.mat')

values=varargin{1};

if length(values)~=6
    for i=1:6
        integrated_regions(i)=nanmedian(values(ind{i}));
    end
    c=integrated_regions;
else
    c=values;
end

if varargin{2} % plotting
    if length(varargin)>2
        cmin=varargin{3};
        cmax=varargin{4};
    else
        m=max(abs(min(c)),abs(max(c)));
        cmin=-m;
        cmax=m;
    end
    
    step=(cmax-cmin)/length(coolWarm);
    for i=1:6
        temp(i)=round((c(i)-cmin)/step)+1;
    end
    temp(temp>length(coolWarm))=length(coolWarm);
    temp(temp<1)=1;
    NOP=1000;
    draw_circle([0,0],1,NOP,':',0.25*pi,0.75*pi,coolWarm(temp(1),:))
    hold on
    draw_circle([0,0],1,NOP,':',0.75*pi,1.15*pi,coolWarm(temp(2),:))
    draw_circle([0,0],1,NOP,':',1.15*pi,1.85*pi,coolWarm(temp(5),:))
    draw_circle([0,0],1,NOP,':',1.3*pi,1.7*pi,coolWarm(temp(6),:))
    draw_circle([0,0],0.7,NOP,':',1.15*pi,1.85*pi,coolWarm(temp(5),:))
    draw_circle([0,0],1,NOP,':',1.85*pi,2.25*pi,coolWarm(temp(4),:))
    draw_circle([0,0],0.4,NOP,':',0,2*pi,coolWarm(temp(3),:))
    caxis([cmin cmax])
    hold off
    axis([-1 1 -1 1])
    axis square
    axis off

end
%     NOP=1000;
%     draw_circle([0,0],1,NOP,':',0.25*pi,0.75*pi,'b')
%     hold on
%     draw_circle([0,0],1,NOP,':',0.75*pi,1.15*pi,'k')
%     draw_circle([0,0],1,NOP,':',1.15*pi,1.85*pi,'y')
%     draw_circle([0,0],1,NOP,':',1.3*pi,1.7*pi,'g')
%     draw_circle([0,0],0.7,NOP,':',1.15*pi,1.85*pi,'y')
%     draw_circle([0,0],1,NOP,':',1.85*pi,2.25*pi,'r')
%     draw_circle([0,0],0.4,NOP,':',0,2*pi,'c')
%     hold off

function draw_circle(center,radius,NOP,style,begin,eind,color)
%---------------------------------------------------------------------------------------------
% H=CIRCLE(CENTER,RADIUS,NOP,STYLE)
% This routine draws a circle with center defined as
% a vector CENTER, radius as a scaler RADIS. NOP is
% the number of points on the circle. As to STYLE,
% use it the same way as you use the rountine PLOT.
% Since the handle of the object is returned, you
% use routine SET to get the best result.
%
%   Usage Examples,
%
%   circle([1,3],3,1000,':');
%   circle([2,4],2,1000,'--');
%
%   Zhenhai Wang <zhenhai@ieee.org>
%   Version 1.00
%   December, 2002
%---------------------------------------------------------------------------------------------

if (nargin <3),
    error('Please see help for INPUT DATA.');
elseif (nargin==3)
    style='b-';
end;
% THETA=linspace(0,2*pi,NOP);
THETA=linspace(begin,eind,NOP);
RHO=ones(1,NOP)*radius;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
% H=plot(X,Y,style);
fill([X,center(1)],[Y,center(2)],color,'linestyle','none')
%  axis equal;
% figure(1)



