function [p]=nbt_StatTest2(A, Grp1, Grp2, Type)
%Perform group test on the matrix A(channel,subjectID)
if(strcmp(Type,'none'))
    p = nan(size(A,1),1);
end
for ChId = 1:size(A,1)
    try
    switch Type
        case 'ttest'
            %Perform a t-test
            [h,p(ChId)] = ttest2(A(ChId,Grp1),A(ChId,Grp2),[],'','unequal');
        case 'perm'
            %Perform a permuation test
            [p(ChId), mean_difference, N_s, p_low, p_high]=nbt_permutationtest(A(ChId,Grp1),A(ChId,Grp2),5000,0,@nanmedian);
        case 'rank'
            %Perform Wilcoxon rank sum test
            [p(ChId)] = ranksum(A(ChId,Grp1),A(ChId,Grp2));
    end
    catch
        p(ChId) = nan;
    end
end
end