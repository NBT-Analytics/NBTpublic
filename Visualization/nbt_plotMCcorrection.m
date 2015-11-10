function nbt_plotMCcorrection(s,stat_results,bioms_name,nameG1,nameG2)
%plot matrix of MC corrected significant biomarkers

if (length(stat_results)>1)
    pvalues = nan(length(stat_results(1).p), length(stat_results));
    for k = 1:length(stat_results)
        pvalues(:,k)  = stat_results(k).p';
    end
else
    pvalues = stat_results.p';
end



PtoPlot = 0.01+zeros(size(pvalues,2), 4);

for i=1:size(pvalues,2)
    if(~isempty(nbt_MCcorrect(pvalues(:,i),'holm')))
        PtoPlot(i,1) = 1;
    end
    if(~isempty(nbt_MCcorrect(pvalues(:,i),'hochberg')))
        PtoPlot(i,2) = 1;
    end
    if(~isempty(nbt_MCcorrect(pvalues(:,i),'bino')))
        PtoPlot(i,3) = 1;
    end
    if(~isempty(nbt_MCcorrect(pvalues(:,i),'bonfi')))
        PtoPlot(i,4) = 1;
    end
end

PtoPlot = PtoPlot';

h1 = figure('Visible','off');
ah=bar3(PtoPlot);
h2 = figure('Visible','on','numbertitle','off','Name',['NBT: Multiple comparison correction for ', s.statfuncname],'position',[10          80       800      800]);
    calctext = text(1,1,'Calculating...');
    drawnow
%--- adapt to screen resolution
h2=nbt_movegui(h2);
%---
bh=bar3(PtoPlot);
for i=1:length(bh)
    zdata = get(ah(i),'Zdata');
    set(bh(i),'cdata',zdata);
end
axis tight

grid off
view(-90,90.01) %the decimal solves a matlab bug.
colorbar('off')
coolWarm = load('nbt_CoolWarm.mat','coolWarm');
coolWarm = coolWarm.coolWarm;
colormap(coolWarm);
cbh = colorbar('EastOutside');

caxis([0 1])

pos_a = get(gca,'Position');
%     pos = get(cbh,'Position');
set(cbh,'Position',[1.2*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
Pos=get(cbh,'position');
set(cbh,'units','normalized');
set(cbh,'YTick', [0 1]);
set(cbh,'YTickLabel', {'N.S.','Significant'})

    for i = 1:length(bioms_name)
        bioms_name{i} = regexprep(bioms_name{i}, '_', ' ');
        
    end
    set(gca, 'XTick', 1:length(bioms_name))
    set(gca, 'XTickLabel', bioms_name)
    set(gca,'YTick',1:size(PtoPlot,1))
    set(gca,'YTickLabel',{'Holm', 'Hochberg', 'Binomial', 'Bonferroni'},'Fontsize',10)
   
    ylabel('Correction method')


title(['Multiple comparison correction for ', s.statfuncname, ' for ''', regexprep(nameG2,'_',''),''' vs ''',regexprep(nameG1,'_',''),''''],'fontweight','bold','fontsize',12)


close(h1)
end



