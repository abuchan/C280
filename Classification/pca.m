%clc; close all; clear all;
%addpath([pwd '/filters']);
%addpath([pwd '/export_fig']);

load ../data/keith;
features = img_to_features(keith);
%load ../../datasets/keith_features_therm_pix

%%

%[coeff score latent] = princomp(features(:,end-64:end));
[coeff score latent] = princomp(features);

figure;
semilogx(100*cumsum(latent)./sum(latent),'LineSmoothing','On','LineWidth',2);