function [labels, counts] = label_counts(dataset)

labels = {''};
counts = 0;

for i = 1:length(dataset)
    if isempty(dataset(i).lbl)
        counts(1) = counts(1) + 1;
    else
        for l = 1:length(dataset(i).lbl)
            match = strcmp(labels, dataset(i).lbl(l));
            if ~any(match)
                labels{end+1} = dataset(i).lbl{l};
                counts = [counts 1];
            else
                counts = counts + match;
            end
        end
    end
end