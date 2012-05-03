img_divs = [0 8*cumsum((448./[224 112 56 28]).^2)];
%thm_divs = 2720 + [0 8*cumsum((8./[8 4 2 1]).^2)];
thm_divs = 2720 + (0:8:64);

acc = zeros(length(img_divs),length(thm_divs));

for i = 1:length(img_divs)
    img = features(:,1:img_divs(i));
        for t = 1:length(thm_divs)
            t_idx = 2721:thm_divs(t);
            thm = features(:,t_idx);
            result = people_classifier([img thm],labels);
            acc(i,t) = result(1);
        end
end

mesh(acc)