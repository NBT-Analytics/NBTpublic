function [p]=nbt_StatTest(A, B ,SubjListA, SubjListB, Type)
%Perform group test on the matrix A(channel,subjectID)

%Check if Subject Lists are matching, and correct if not
[A, B, SubjListA, SubjListB] = nbt_MatchVectors(A, B, SubjListA, SubjListB, 0, 1);

if(~isempty(A) & ~isempty(B) & (size(B,2) > 1) & (size(A,2) > 1))
    
    for ChId = 1:size(A,1)
        switch Type
            case 'ttest'
                %Perform a t-test
                if(nanmean(A(ChId,:)) ~= nanmean(B(ChId,:)))
                    [h,p(ChId)] = ttest(A(ChId,:),B(ChId,:));
                else
                    p(ChId) = 1;
                end
            case 'perm'
                %Perform a permuation test
                [p(ChId), mean_difference, N_s, p_low, p_high]=nbt_permutationtest(A(ChId,:),B(ChId,:),5000,1,@nanmedian);
            case 'rank'
                %Perform Wilcoxon rank sum test
                [p(ChId)] = signtest(A(ChId,:),B(ChId,:));
        end
    end
else
    p = nan;
end
end