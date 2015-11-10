function nbt_plotBadChannels(EEG)
        badchan = find(EEG.NBTinfo.BadChannels);
        if(~isempty(badchan))
        colors = cell(1,size(EEG.data,1)); colors(:) = { 'k' };
        colors(badchan) = { 'r' }; colors = colors(end:-1:1);
        eegplot(EEG.data,'color',colors); %plot bad channels
        vector = zeros(1,EEG.nbchan);
        vector(badchan) = 1;
        figure
        set(gcf,'numbertitle','off');
        set(gcf,'name','NBT: EEG Topography');
        nbt_plot_EEG_channels_and_numbers(vector,badchan,[],EEG)
        else
            disp('No bad channels')
        end
end