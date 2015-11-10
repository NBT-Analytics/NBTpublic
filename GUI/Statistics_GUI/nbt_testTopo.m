function nbt_testTopo(d1,d2,electrodehandle)
    pos = get(gca,'currentpoint');
    xdata = get(electrodehandle,'xdata');
    ydata = get(electrodehandle,'ydata');
    
    for i = 1:129
        elec(i) =((pos(1,1)-xdata(i))^2 + (pos(1,2) - ydata(i))^0.5)^0.5;
    end
    
    elec = find(elec == min(elec));
    elec = elec(1)


end