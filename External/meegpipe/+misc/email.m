function email(text, address)


if strcmpi(text, 'reconfigure'),
    mail = input('Email address: ', 's');
    password = input('Password: ', 's');
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    return;
end


% Send the email. Note that the first input is the address you are sending
% the email to
sendmail(address, text)