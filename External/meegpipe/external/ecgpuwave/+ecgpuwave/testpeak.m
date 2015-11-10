function pic=testpeak(X,pic,Fs,p)

% ---- Adjust the correspondence between the null-derivative criterium
% peak and the ECG signal peak ----

kpos=round(10e-3*Fs);
laux=pic;
Xaux=X(pic-kpos:pic+kpos);
if p==1
   [mpic,iaux]=max(Xaux);
else
   [mpic,iaux]=min(Xaux);
end
pic=pic-kpos+iaux-1;
   
