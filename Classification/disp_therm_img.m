function disp_therm_img(imgs,temp_range,temp_pos)

if nargin < 2
    temp_range = [2900 3000];
end
if nargin < 3
    temp_pos = [150 0 450];
end

clf

n_img = length(imgs);

for r = 1:3
    for c = 1:4
        i = r+3*(c-1);
        if i <= n_img
            h = subplot(3,4,i);
            p = get(h, 'pos');
            p = p + [0 0 0.04 0.04];
            set(h,'pos',p);
            imagesc(imgs(i).img)
            axis equal
            axis off
            axis([0 640 0 480])
            hold on
            thermal = zeros(9);
            thermal(1:8,1:8) = imgs(i).thm;
            h = pcolor(linspace(temp_pos(1),temp_pos(1)+temp_pos(3),9),...
                linspace(temp_pos(2),temp_pos(2)+temp_pos(3),9),...
                thermal);
            set(h,'FaceAlpha',0.4,'lineStyle','none')
            caxis(temp_range)
        end
    end
end