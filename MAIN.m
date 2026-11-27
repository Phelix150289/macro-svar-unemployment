% Replication and Extension of King & Morley (2007)
% "In Search of the Natural Rate of Unemployment"
% Journal of Monetary Economics
%%
clear all
clc
addpath(genpath('_func'))
addpath('datasets')
addpath('other_scripts')
%% Preliminaries
% SVAR lag order
p = 8;
% 1948Q2 to 2001Q1 (Baseline) / 2010Q1 (Extended)
dates = (1948.25:0.25:2001.0)';
% Stage 1 SVAR estimation and Beveridge-Nelson decomposition
setup_dataset
tic
%% Generate Baseline Figures and Tables (1948-2001)
Figure_1
Figure_2
Figure_3
Table_1
%% Generate Extended Figures and Tables (1948-2010)
% Wider replication extending the sample through the Global Financial Crisis
Figure_4_Extended
Figure_5_Extended
Figure_6_Extended
Table_2_Extended
disp('Total Time Taken')
toc