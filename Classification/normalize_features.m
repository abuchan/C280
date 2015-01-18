function [ norm_features offsets weights ] = normalize_features( features, offsets, weights )
%NORMALIZE_FEATURES Normalize the columns of a feature matrix
%   Author: Ryan C. Julian
norm_features = zeros(size(features));

% Calculate offsets and weights, if not provided
if nargin == 1
    offsets = min(features,[],1);
    weights = 1./(max(features,[],1)-min(features,[],1));
end

% Normalize
% Xu Cui
% http://www.alivelearn.net/?p=912
norm_features = (features - repmat(offsets,size(features,1),1))*spdiags(weights',0,size(features,2),size(features,2));

