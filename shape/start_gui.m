clc;
clear;
close all;

addpath('shapebm/');
addpath('util/');
addpath('gui/');

fprintf('==============================================================\n');
fprintf('ShapeBM Interactive GUI\n');
fprintf('--------------------------------------------------------------\n');
fprintf('''The Shape Boltzmann Machine: a Strong Model of Object Shape''\n');
fprintf('S. M. Ali Eslami, Nicolas Heess and John Winn\n');
fprintf('Computer Vision and Pattern Recognition (CVPR) 2012\n');
fprintf('==============================================================\n');
fprintf('\n');

% -------------------------------------------------------------------------
% load the ShapeBM parameters
fprintf('Loading ShapeBM parameters for motorbikes... \t');
shapebm_params_motorbikes = deserialize('params/shapebm_motorbikes_params.mat');
fprintf('Done.\n');

fprintf('Loading ShapeBM parameters for horses... \t');
shapebm_params_horses = deserialize('params/shapebm_horses_params.mat');
fprintf('Done.\n');

% -------------------------------------------------------------------------
% load the datasets
fprintf('Loading held out motorbikes... \t\t\t');
dataset_motorbikes = deserialize('data/held_out_motorbikes.mat');
fprintf('Done.\n');

fprintf('Loading held out horses... \t\t\t');
dataset_horses = deserialize('data/held_out_horses.mat');
fprintf('Done.\n');

% -------------------------------------------------------------------------
% start the gui
fprintf('Initializing the GUI... \t\t\t');
gui(shapebm_params_motorbikes, shapebm_params_horses, dataset_motorbikes, dataset_horses);
fprintf('Done.\n\n');


