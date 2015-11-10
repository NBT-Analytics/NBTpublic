function cb = nbt_plot_EEG_channels(c,minValue, maxValue, chanlocs,nbtColorMap, legend, LogScaleSwitch)
error(nargchk(6, 7, nargin))

if ~isempty(minValue)
    cmin=minValue;
    cmax=maxValue;
else
    %     cmin=min(c);
    %     cmax=max(c);
    m=max(abs(min(c)),abs(max(c)));
    cmin=-m;
    cmax=m;
end


% if length(varargin)>3
%     color=color(500:end,:);
%     step=(cmax-cmin)/500;
% else

   
    
 

% end

 cstep=(cmax-cmin)/length(nbtColorMap);
   for i=1:length(c)
        temp(i)= round((c(i)-cmin)/cstep)+1;
    end
    temp(temp>length(nbtColorMap))=length(nbtColorMap);
    temp(temp<1) = 1;


[intx,inty]=nbt_loadintxinty(chanlocs);

for i=1:length(c)
    try
    plot(inty(i),intx(i),'.','color',nbtColorMap(temp(i),:),'markersize',15)
    hold on
    catch
    end
end

axis off
ew = max([abs(intx) abs(inty)]);
axis([-ew ew -ew ew]);
OldColorMap = colormap;
colormap(nbtColorMap)
cb = colorbar('westoutside');
axis square
set(get(cb,'title'),'String',legend);
set(gca,'fontsize',10)

    
    
drawnow
caxis([cmin,cmax])
% colorbar
%axis off
hold off
 
if(strcmp(legend, 'P-values'))
   set(cb,'YTick',[-2.3010 -1.3010 0 1.3010 2.3010])
       set(cb,'YTicklabel',[0.005 0.05 0 0.05 0.005])
end
    

%   axis equal
cbfreeze
colormap(OldColorMap);
end
