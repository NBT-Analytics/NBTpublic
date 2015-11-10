function[] = plot_channels_with_small_p_value(p_values,threshold)


temp=find(p_values<threshold);
vector=zeros(1,129);
vector(temp)=1;
if ~isempty(temp)
%     figure(1)
nbt_plot_eeg_channels_and_numbers(vector,temp,p_values)
title(['P-values smaller than ',num2str(threshold)])
disp('channel nr    P-value')
disp([temp;p_values(temp)]')
else
    disp(['No P-values smaller than ',num2str(threshold)])
end
% for i=1:length(temp)
