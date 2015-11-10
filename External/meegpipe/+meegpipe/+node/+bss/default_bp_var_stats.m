function stats = default_bp_var_stats()

stats = mjava.hash;
stats('10%') = @(x) prctile(10*log10(x.^2), 10);
stats('90%') = @(x) prctile(10*log10(x.^2), 90);



end