%% Test HMM functions of real data
clc
clear all

data = xlsread('WIKI-FLWS.xls');

% Get opening price
open = data(2:round(size(data,1)/5),2)';

% Get closing price
close = data(2:round(size(data,1)/5),5)';

% Get intraday movement
movement = open - close;

% Create 3 observable states: [Rise, Constant, Drop]
seq = zeros(size(movement));
seq(movement<0) = 1;
seq(movement==0) = 2;
seq(movement>0) = 3;

% Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
biggestChange = max(movement) - min(movement);
delta = biggestChange/30;
a = -delta;
b = delta;

% Create state-matrix [5x5]
states = zeros(size(movement));
states(movement < 3*a) = 1;
states(movement >= 3*a & movement < a) = 2;
states(movement >= a & movement < b) = 3;
states(movement >= b & movement < 3*b) = 4;
states(movement >= 3*b ) = 5;

% ESTIMATE MATRICES
% Get estimate of transition and emision matrix
[trans_est, emis_est] = hmmestimate(seq, states);


% TRAIN THE HMM
% Specify maximal number of iterations. Default is 500
maxiter = 1000;

% Estimate the two matrices
[trans_train, emis_train] = hmmtrain(seq, trans_est, emis_est,'maxiterations',maxiter);

trans_diff = trans_train - trans_est;
disp(trans_diff)

emis_diff = emis_train - emis_est;
disp(emis_diff)

% PROGNOSIS
% Use Viterbi to estimate most probable state sequence
likelystates = hmmviterbi(seq, trans_train, emis_train);

subplot(2,1,1)
plot(1:length(seq), states,'b*-', 1:length(seq), likelystates,'r*-');

close_prog(likelystates == 1) = open(likelystates == 1) + 4*a;
close_prog(likelystates == 2) = open(likelystates == 2) + 2*a;
close_prog(likelystates == 3) = open(likelystates == 3) + 0;
close_prog(likelystates == 4) = open(likelystates == 4) + 2*b;
close_prog(likelystates == 5) = open(likelystates == 5) + 4*b;

subplot(2,1,2)
plot(1:length(seq), close,'b*-', 1:length(seq), close_prog,'r*-');