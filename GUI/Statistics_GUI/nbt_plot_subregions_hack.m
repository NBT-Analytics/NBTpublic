function[integrated_regions]= nbt_plot_subregions_hack(data,cmin,cmax)

 coolWarm = load('nbt_CoolWarm.mat','coolWarm');
        coolWarm = coolWarm.coolWarm;
%        colormap(coolWarm);
      
    c = data;
    step=(cmax-cmin)/256;
    for i=1:6
        temp(i)=round((c(i)-cmin)/step)+1;
    end
    temp(temp>256)=256;
    temp(temp<1)=1;
    NOP=300;
    draw_circle([0,0],1,NOP,':',0.25*pi,0.75*pi,coolWarm(1,:))
    hold on
    draw_circle([0,0],1,NOP,':',0.25*pi,0.75*pi,coolWarm(temp(1),:))
    axis([-1.1 1.1 -1.1 1.1])
    %hold on
   draw_circle([0,0],1,NOP,':',0.75*pi,1.15*pi,coolWarm(temp(2),:))
    draw_circle([0,0],1,NOP,':',1.15*pi,1.85*pi,coolWarm(temp(5),:))
    draw_circle([0,0],1,NOP,':',1.3*pi,1.7*pi,coolWarm(temp(6),:))
    draw_circle([0,0],0.7,NOP,':',1.15*pi,1.85*pi,coolWarm(temp(5),:))
    draw_circle([0,0],1,NOP,':',1.85*pi,2.25*pi,coolWarm(temp(4),:))
   
    draw_circle([0,0],0.4,NOP,':',0,2*pi,coolWarm(temp(3),:))
    caxis([cmin cmax])
    hold off

    axis square
    axis off


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
end
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

end

