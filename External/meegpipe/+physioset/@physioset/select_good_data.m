function data = select_good_data(data)

% New implementation simply uses selections
rowsSel     = ~is_bad_channel(data);
colsSel     = ~is_bad_sample(data);
select(data, find(rowsSel), find(colsSel));


end