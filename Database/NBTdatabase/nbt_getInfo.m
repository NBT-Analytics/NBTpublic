function  [conditions]=nbt_getInfo(path)

load([path '/' 'ProjectInfo.mat'])
conditions = fieldnames(ProjectInfo.Info.ProjectInfo.condition);

end