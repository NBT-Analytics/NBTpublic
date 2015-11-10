

function s=nbt_run_stat_multiGroup(B_values,s,MaxGroupSize,NCHANNELS, bioms_name,unit)
%  We first create a Matrix for the multiple group statistical function
pvalues = nan(1,NCHANNELS);
DataCell = cell(NCHANNELS, 1);
MultiStats = cell(NCHANNELS, 1);

if(strcmp(s(1).statname, 'n-way ANOVA'))
    %define factors
    %How many factors
    nfactors = input('How many factors do you want to define ');
    %Ask factor groups
    for i=1:nfactors
        afactor{i,1} = input(['Define factor ' num2str(i) ' '],'s');
    end
    for GrpId=1:length(B_values)
        for i=1:nfactors
            afactor{i,GrpId+1} = input(['Define factor level for Group ' num2str(GrpId) ' factor ' afactor{i,1} ' : ']);
        end
    end
end


for BId = 1:length(bioms_name)
    if (strcmp(s(1).statname, 'dotplotmedian'))
         nbt_DotPlot(figure, 0.1, 0.025, 1, @median, {'One'; 'Two';'Three'; 'Biomarker value'},'', B_values{1,1}(:,:,BId)',1:size(B_values{1,1}(:,:,BId)',2), 1:size(B_values{1,1}(:,:,BId)',1), B_values{2,1}(:,:,BId)',1:size(B_values{2,1}(:,:,BId)',2), 1:size(B_values{2,1}(:,:,BId)',1),B_values{3,1}(:,:,BId)',1:size(B_values{3,1}(:,:,BId)',2), 1:size(B_values{3,1}(:,:,BId)',1));
    else
        for ChId = 1:NCHANNELS
            DataMatrix = nan(MaxGroupSize,length(B_values));
            for GrpId = 1:length(B_values)
                B_Data = B_values{GrpId,1}(ChId,:,BId)';
                DataMatrix(1:length(B_Data), GrpId) = B_Data;
            end
            DataCell{ChId,1} = DataMatrix;
            
            
            %run statistics
            if (strcmp(s(1).statname, 'One-way ANOVA'))
                [pvalues(ChId), table, MultiStats{ChId, 1}] = anova1(DataMatrix,[],'off');
            elseif(strcmp(s(1).statfuncname, 'Two-way ANOVA'))
                if(any(isnan(DataMatrix)))
                    DataMatrix=removeNANsubjects(DataMatrix);
                end
                [dummy, table, MultiStats{ChId, 1}] = anova2(DataMatrix,[],'off');
                F = table(2,5);
                pvalues(ChId) = adjPF(DataMatrix,F{1,1});
            elseif(strcmp(s(1).statname, 'n-way ANOVA'))
                %use factors defined above
                    DataVector = [];
                    Group = cell(1,nfactors);
                    for GrpId=1:length(B_values)
                       DataVector = [DataVector B_values{GrpId,1}(ChId,:,BId)];
                       for i=1:nfactors
                            Group{1,i} = [Group{1,i} repmat(afactor{i,GrpId+1},1,length(B_values{GrpId,1}(ChId,:,BId)))];
                       end
                    end
                    [p,table, MultiStats{ChId,1}] = anovan(DataVector',Group,'display','off'); 
                    pvalues(ChId) = p(1);
            elseif(strcmp(s(1).statname, 'Kruskal-Wallis test'))
                [pvalues(ChId), t, MultiStats{ChId, 1}] = kruskalwallis(DataMatrix,[],'off');
            elseif(strcmp(s(1).statname, 'Friedman test'))
                if(any(isnan(DataMatrix)))
                    DataMatrix=removeNANsubjects(DataMatrix);
                end
                [dummy Table MultiStats{ChId, 1},F]=friedmanGG(DataMatrix,[],'off');
                % yes correct to use F stat.. see Conover 1981
                pvalues(ChId) = adjPF(DataMatrix,F{1,1});
            else
                error('This test is not supported for multiple groups designs');
            end
        end
        s(BId).statistic = s(1).statistic;
        s(BId).statfunc = s(1).statfunc;
        s(BId).statfuncname  = s(1).statfuncname;
        s(BId).statname = s(1).statname;
        s(BId).p = pvalues;
        s(BId).DataCell = DataCell;
        s(BId).MultiStats = MultiStats;
        s(BId).biom_name = bioms_name{BId};
        s(BId).unit = unit;
    end
end


end

function Data2 = removeNANsubjects(Data)
%removes subjects with any missing values
NaNswitch = sum(isnan(Data'));
Data2 = [];
for i=1:length(NaNswitch)
    if (NaNswitch(i) == 0)
        Data2 = [Data2; Data(i,interval)];
    end
end
warning('Missing values detected. Subjects with missing values have been removed from the statistical test');
end