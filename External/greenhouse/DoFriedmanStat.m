function p=DoFriedmanStat(Data,interval)
NaNswitch = sum(isnan(Data(:,interval)'));
Data2 = [];
for i=1:length(NaNswitch)
    if (NaNswitch(i) == 0)
        Data2 = [Data2; Data(i,interval)];
    end
end
[P,Table,stat,F]=friedmanGG(Data2);
% yes correct to use F stat.. see Conover 1981
p = adjPF(Data2,F{1,1})
disp('N=')
disp(size(Data2))
if(p<0.05)
disp('Seems to be significant p <0.05')
end

disp('Anova 2 result')
[p,table] = anova2(Data2);
F = table(2,5);
disp(adjPF(Data2,F{1,1}))

end