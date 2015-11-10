trait{1}='amplitude_1_4_Hz';
trait{2}='amplitude_4_8_Hz';
trait{3}='amplitude_8_13_Hz';
trait{4}='amplitude_13_30_Hz';
trait{5}='amplitude_30_45_Hz';
trait{6}='amplitude_1_4_Hz_Normalized';
trait{7}='amplitude_4_8_Hz_Normalized';
trait{8}='amplitude_8_13_Hz_Normalized';
trait{9}='amplitude_13_30_Hz_Normalized';
trait{10}='amplitude_30_45_Hz_Normalized';

for i=1:length(trait)
%     statistics('B:\NBT Data\course','first_5_min','last_5_min',trait{i},1);
    nbt_statistics_sleep('B:\NBT Data\course','first_5_min','last_5_min',trait{i},1);
end