% OctoRoACH Terrain Classifier
% Author: Ryan C. Julian
clc; close all; clear all;
addpath([pwd '\libsvm-3.11\windows']);
addpath([pwd '\filters']);
addpath([pwd '\export_fig']);
%% Classifier parameters
DATA_DIR        = 'terrain_data_ABCD'; % Name of directory with terrain data
TRIM            = 0.25;             % Seconds to trim from input data
SAMPLING_RATE   = 300;              % Data sampling rate
EPISODE_LENGTH  = 0.35;             % Length of a training episode in seconds
MIN_SPEED       = 3.3894;           % Minimum (rps) speed to attempt classification 
MAX_SPEED       = 20;               % Max (rps) speed to accept (filters out speed calculation errors)
TEST_PERCENT    = 0.25;             % Proportion the data reserved for testing
SLIDING_WINDOW  = 0.167;            % Window size (in seconds) for sliding filters
TRAIN_OPTIONS   = '-s 0 -t 2';      % LIBSVM training options
GAMMA           = 1.31951;          % RBF kernel standard deviation
SOFT_MARGIN     = 181.019;          % SVM soft margin
PREDICT_OPTIONS = '';               % LIBSVM predict options

%% Import data
fprintf('Importing data...\n');
terrain_data = import_terrain_data(DATA_DIR, TRIM, SAMPLING_RATE);
save('terrain_data_ABCD.mat','terrain_data');

%% Generate uniform-length episodes
% load terrain_data;
fprintf('Generating episodes...\n');
[episodes labels groups] = generate_episodes(terrain_data, EPISODE_LENGTH);
save('episodes_ABCD.mat','episodes','groups','labels');

%% Partitiion the episodes into training and test sets
% load episodes;
fprintf('Separating training and test episodes...\n');
[train test] = crossvalind('HoldOut', groups, TEST_PERCENT);

%% Generate features
fprintf('Extracting feature vectors...\n');
% Make a dictionary for label numbers
unique_labels = unique(labels);
label_mapping = containers.Map( unique_labels, 1:length(unique_labels) );

% Generate feature vectors
n_window = round(SAMPLING_RATE*SLIDING_WINDOW);
[train_features train_labels] = generate_features(episodes(train), labels(train), label_mapping, n_window);
[test_features test_labels] = generate_features(episodes(test), labels(test), label_mapping, n_window);
%save('features.mat','train_features','train_labels','test_features','test_labels');

% Remove low and (too) high
keep = train_features(:,1) > MIN_SPEED & train_features(:,1) < MAX_SPEED;
train_features = train_features(keep,:);
train_labels = train_labels(keep,:);

keep = test_features(:,1) > MIN_SPEED & test_features(:,1) < MAX_SPEED;
test_features = test_features(keep,:);
test_labels = test_labels(keep,:);

% Normalize the features to [0,1]
[train_features, offsets, weights] = normalize_features(train_features);
test_features = normalize_features(test_features, offsets, weights);

save('train_features_ABCD.mat','train_features','train_labels');

%% Train the SVM using the training set
fprintf('Training...\n');
% Automatic grid search tuning
% Source: Xu Cui, http://www.alivelearn.net/?p=912, via LibSVM
% RBF
% bestcv = 0;
% for log2c = 7.4:0.05:7.6
%   for log2g = 0.3:0.05:0.5
%     cmd = ['-q -v 10 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%     cv = svmtrain(train_labels, train_features, cmd);
%     if (cv >= bestcv),
%       bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
%     end
%     fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
%   end
% end
% % Linear
% bestcv = 0;
% for log2c = -0.1:0.1:5,
%     cmd = ['-t 0 -q -v 10 -c ', num2str(2^log2c)];
%     cv = svmtrain(train_labels, train_features, cmd);
%     if (cv >= bestcv),
%       bestcv = cv; bestc = 2^log2c;
%     end
%     fprintf('%g %g (best c=%g, rate=%g)\n', log2c, cv, bestc, bestcv);
% end
% Polynomial
% bestcv = 0;
% for deg = 1:5
%     for log2c = 1:0.5:5,
%       for log2g = -2:0.5:2
%           for log2coef = -6:0.5:6
%             cmd = ['-t 1 -q -v 10 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
%             cv = svmtrain(train_labels, train_features, cmd);
%             if (cv >= bestcv),
%               bestcv = cv; bestc = 2^log2c; bestg = 2^log2g; bestcoef = 2^log2coef; bestdeg = deg;
%             end
%             fprintf('%g %g %g %g %g (best c=%g, g=%g, doef0=%g, deg=%g, rate=%g)\n', log2c, log2g, log2coef, deg, cv, bestc, bestg, bestcoef, bestdeg, bestcv);
%           end
%       end
%     end
% end
tic;
model = svmtrain(train_labels, train_features, [TRAIN_OPTIONS ' -g ' num2str(GAMMA) ' -c ' num2str(SOFT_MARGIN)]);
toc;
%save('model.mat','model');

%% Evaluate performance using the test set
fprintf('Testing...\n');
[predicted_labels, accuracy, decision] = svmpredict(test_labels, test_features, model, PREDICT_OPTIONS);
for t = 1:length(unique_labels)     % True
    for p = 1:length(unique_labels) % Predicted
        true_set = (test_labels == t);
        pred_set = (test_labels == t) & (predicted_labels == p);
        display(sprintf('True: %s, Predicted: %s, %f %%', unique_labels{t}, unique_labels{p}, 100*sum(pred_set)/sum(true_set)));
    end
end