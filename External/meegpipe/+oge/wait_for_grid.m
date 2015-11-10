function wait_for_grid(regex)

if ~oge.has_oge,
    return;
end

[~, res] = system('qstat');

if ~isempty(res) && ~isempty(regexp(res, regex, 'once')),
    fprintf('(wait_for_grid) Waiting for ''%s'' jobs to finish...\n\n', regex);
end

while ~isempty(res) && ~isempty(regexp(res, regex, 'once'))         
      pause(60);
      [~, res] = system('qstat');
end

end