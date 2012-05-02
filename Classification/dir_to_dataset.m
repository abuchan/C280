function dataset = dir_to_dataset(directory)

files = dir(sprintf('%s/*.png',directory));
n_files = length(files);

dataset(n_files) = struct('img', NaN*ones(480,640,3), 'thm', NaN*ones(8), 'lbl',[]);

for n = 1:n_files
	dataset(n).img = imread(sprintf('%s/%s',directory,files(n).name));
    
    thm_name = sprintf('%s/therm_%s.txt',directory,files(n).name(5:8));
    if exist(thm_name,'file')
        dataset(n).thm = csvread(thm_name);
    end
    
    lbl_name = sprintf('%s/lbl_%s.txt',directory,files(n).name(5:8));
    if exist(lbl_name, 'file')
        dataset(n).lbl = importdata(lbl_name);
        if isempty(dataset(n).lbl)
            dataset(n).lbl = {};
        end
    else
        dataset(n).lbl = {};
    end
    
end