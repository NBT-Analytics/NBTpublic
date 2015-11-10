function spf = match_sources(spf, A)

import misc.nearest2;

[~, P] = nearest2(projmat(spf)*A, pinv(A)*A);
spf.W = P*spf.W;
spf.A = spf.A*P';

% Fix the scale and the sign

Wa = pinv(A);
for i = 1:size(spf.W,1)
    scale = Wa(i,:)*pinv(spf.W(i,:));
    spf.W(i,:) = spf.W(i,:)*scale;
    spf.A(:,i) = spf.A(:,i)/scale;
end

selected = false(nb_component(spf), 1);
selected(spf.ComponentSelection) = true;
spf.ComponentSelection = find(P*selected);


end