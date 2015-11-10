function [A, B, SubjListA, SubjListB]=nbt_MatchVectors(A, B, SubjListA, SubjListB, NaNFlag, HarmonizeFlag)
% 
 if(size(A,2) == 1 & size(A,1) > 1)
     A = A';
 end
 
 if(size(B,2) == 1 & size(B,1) > 1)
     B = B';
 end
    
    
if(HarmonizeFlag)
    %Check if Subject Lists are matching, and correct if not
    SubjectIndex = nbt_searchvector(SubjListA,SubjListB);
    A = A(:,SubjectIndex);
    SubjListA = SubjListA(SubjectIndex);
    SubjectIndex = nbt_searchvector(SubjListB,SubjListA);
    B = B(:,SubjectIndex);
    SubjListB = SubjListB(SubjectIndex);
end
if(NaNFlag)
    if(size(A,1) ==1 && size(B,1) == 1)
    B = B(~isnan(A));
    A = A(~isnan(A));
    A = A(~isnan(B));
    B = B(~isnan(B));
    end
end
end