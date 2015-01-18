function out_img = img_to_clipped_gray(in_img)

r_min = 1;
c_min = 151;
width = 448;

out_img = double(mean(in_img(...
    r_min:(r_min+width-1),c_min:(c_min+width-1),:),3))/255;