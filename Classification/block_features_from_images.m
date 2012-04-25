function features = block_features_from_images(images, block_sizes, block_functions)

n_row = size(images,1);
n_col = size(images,2);
n_img = size(images,3);

total_n_features = 0;
for c_i = 1:length(block_sizes)
    fun = block_functions{c_i};
    c = block_sizes(c_i);
    total_n_features = total_n_features + length(fun(zeros(c),c))*n_row*n_col/(c^2);
end

features = zeros(total_n_features,n_img);

feature_start = 0;

for c_i = 1:length(block_sizes)
    fun = block_functions{c_i};
    c = block_sizes(c_i);
    n_features = length(fun(zeros(c),c));
    
    for i = 1:n_img    
        for j = 0:((n_row/c)-1)
            for k = 1:(n_col/c)
                p_i = n_col/c*j+k;
                x_i = (1:n_row >= c*j+1) & (1:n_row <= c*(j+1));
                y_i = (1:n_col >= c*(k-1)+1) & (1:n_col<=c*k);
                f_i = feature_start+((n_features*(p_i-1)+1):(n_features*(p_i)));
                features(f_i,i) = fun(images(x_i,y_i,i),c);
            end
        end
    end
    
    feature_start = feature_start + n_features*n_row*n_col/(c^2);
end
