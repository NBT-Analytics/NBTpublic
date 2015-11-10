function[] = nbt_plot_EEG_channels_and_numbers(c,ind,p,EEG)

p=round(p*1000)/1000;

m=max(abs(min(c)),abs(max(c)));
cmin=-m;
cmax=m;
color=jet(1001);
step=(cmax-cmin)/1000;

for i=1:EEG.nbchan
    temp(i)=round((c(i)-cmin)/step)+1;
end

[intx,inty]=nbt_loadintxinty(EEG.chanlocs);

for i=1:EEG.nbchan
    plot(inty(i),intx(i),'.','color',color(temp(i),:),'markersize',15)
    hold on
end
if islogical(ind)
    for i=find(ind == 1)
        text(inty(i)+0.01,intx(i)+0.01,num2str(i),'fontsize',8)
        if(~isempty(p))
        text(inty(i)-0.02,intx(i)-0.02,num2str(p(i)),'fontsize',8)
        end
    end
else
    for i=ind
        text(inty(i)+0.01,intx(i)+0.01,num2str(i),'fontsize',8)
        if(~isempty(p))
        text(inty(i)-0.02,intx(i)-0.02,num2str(p(i)),'fontsize',8)
        end
    end
end
    
caxis([cmin cmax])
% colorbar
axis off
hold off
%   axis equal
end



