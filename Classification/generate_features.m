function [ features feature_labels ] = generate_features( episodes, episode_labels, label_mapping, window )
%GENERATE_FEATURES Generate terrain classifier features
% Author: Ryan C. Julian

% Iterate over episodes
feature_labels = [];
features = [];
for i = 1:length(episodes)
    %feature_labels = [feature_labels; label_mapping(char(episode_labels(i)))*ones(length(episodes{i}.Time),1)];
    feature_labels = [feature_labels; label_mapping(char(episode_labels(i)))];
    features = [features; features_from_episode(episodes{i}, window)];
end

end