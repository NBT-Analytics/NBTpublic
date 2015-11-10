function pic=testpic(X,pic,Fs,p)

%Comprueba si el pico encontrado con el criterio de la
%derivada nula se corresponde con el pico de la señal
%ECG.

kpos=round(10e-3*Fs);
laux=pic;
Xaux=X(pic-kpos:pic+kpos);
if p==1
   [mpic,iaux]=max(Xaux);
else
   [mpic,iaux]=min(Xaux);
end
pic=pic-kpos+iaux-1;
   
