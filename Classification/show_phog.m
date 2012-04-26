function show_phog(img, n_bins, block_sizes, features)

clf


dirs = (-pi+pi/n_bins):(2*pi/n_bins):(pi-pi/n_bins);

% Rotate by pi/2 to show the edge that is most aligned with angle
arrows_y = cos(dirs);
arrows_x = sin(dirs);

n_pyr = length(block_sizes);

subplot(1,(n_pyr+1),1)
imshow(img)

f_idx = 1:n_bins;

for p = 1:n_pyr
    n_div = size(img,1)/block_sizes(p);
    
    subplot(1,(n_pyr+1),p+1)
    hold on
    axis equal
    axis([0 2*n_div 0 2*n_div]) 
    
    for c = 0:(n_div-1)
        for r = 0:(n_div-1)
            x_c = 1+2*r;
            y_c = (2*n_div-1)-2*c;
            
            weights = features(f_idx);
            plot([x_c*ones(1,n_bins);x_c+arrows_x.*weights'],...
                [y_c*ones(1,n_bins);y_c+arrows_y.*weights'])
            f_idx = f_idx + n_bins;
        end
    end
end