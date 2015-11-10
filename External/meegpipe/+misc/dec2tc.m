function value = dec2tc(dec, N)
value = dec2bin(mod((dec),2^N),N);
end