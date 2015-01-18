function features = img_to_features(dataset)

n_img = length(dataset);

width = 448;
img_block_sizes = [224 112 56 28];
%img_block_sizes = [224];
thm_block_sizes = [8 4 2 1];

n_bins = 8;
dir_edges = -pi:(2*pi/n_bins):pi;

gd_filter = conv([-1 1],fspecial('gaussian',[1 4],1));
tap_filter = [-1 0 1];

hog = @(block,n,filter) histc(reshape(atan2(conv2(block,filter','same'),...
    conv2(block,filter,'same')),[n^2,1]),dir_edges);

hog_tap = @(block,n) hog(block,n,tap_filter)/(n^2);

hog_no_norm = @(block,n) hog(block,n,tap_filter);

hog_gaussian = @(block,n) hog(block,n,gd_filter)/(n^2);

hnh = @(block,n) hog_norm_hist(block,n,tap_filter,dir_edges);

flat_norm = @(block,n) reshape(block,[1 n^2]);

imgs = zeros(width,width,n_img);
thms = zeros(8,8,n_img);

for i = 1:n_img
    %Construct windowed greyscale images
    imgs(:,:,i) = img_to_clipped_gray(dataset(i).img);
    thms(:,:,i) = dataset(i).thm(1:8,1:8);
    max_t = max(max(thms(:,:,i)));
    min_t = min(min(thms(:,:,i)));
    thms(:,:,i) = (thms(:,:,i) - min_t)./(max_t-min_t);
end

features = block_features_from_images(imgs, img_block_sizes, {hnh hnh hnh hnh});
%features = [features block_features_from_images(thms, thm_block_sizes, {hnh hnh hnh hnh})];
features = [features block_features_from_images(thms, [8], {flat_norm})];
features(isnan(features)) = 0;