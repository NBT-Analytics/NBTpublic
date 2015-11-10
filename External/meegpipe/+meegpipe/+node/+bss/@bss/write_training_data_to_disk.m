function write_training_data_to_disk(obj, featVal)

fid = get_log(obj, 'criterion_training.csv');
dlmwrite(misc.fid2fname(fid), featVal, 'delimiter', ',', 'precision', 6);

end