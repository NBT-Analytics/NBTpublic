function y = get_username

if isunix,
    y = getenv('USER');
else
    y = getenv('UserName');
end

end