function features = img_to_features(dataset)

r_min = 1;
c_min = 151;
width = 448;

n_img = length(dataset);

img_block_sizes = [448 224 112];
thm_block_sizes = [8 4 2];
    
direction_bins = -pi:2*pi/9:pi;

gd_filter = conv([-1 1],fspecial('gaussian',[1 4],1));
tap_filter = [-1 0 1];

hog = @(block,n,filter) histc(reshape(atan2(conv2(block,filter','same'),...
    conv2(block,filter,'same')),[n^2,1]),direction_bins);

hog_tap = @(block,n) hog(block,n,tap_filter)/(n^2);

hog_no_norm = @(block,n) hog(block,n,tap_filter);

hog_gaussian = @(block,n) hog(block,n,gd_filter)/(n^2);

imgs = zeros(width,width,n_img);
thms = zeros(8,8,n_img);

for i = 1:n_img
    %Construct windowed greyscale images
    imgs(:,:,i) = double(mean(dataset(i).img(...
        r_min:(r_min+width-1),c_min:(c_min+width-1),:),3))/255;

    thms(:,:,i) = dataset(i).thm;
    max_t = max(max(thms(:,:,i)));
    min_t = min(min(thms(:,:,i)));
    thms(:,:,i) = (thms(:,:,i) - min_t)./(max_t-min_t);
end

img_features = block_features_from_images(imgs, img_block_sizes, {hog_tap hog_tap hog_tap});
thm_features = block_features_from_images(thms, thm_block_sizes, {hog_tap hog_tap hog_tap});

features = [img_features; thm_features];