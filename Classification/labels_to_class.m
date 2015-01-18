function labels = labels_to_class(dataset, include, exclude)

labels = zeros(length(dataset),1);

if nargin < 3
    exclude = '';
end

for i = 1:length(dataset)
    labels(i) = (any(strcmp(dataset(i).lbl,include)) && ~any(strcmp(dataset(i).lbl,exclude)))+1;
end