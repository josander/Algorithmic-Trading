%% Testing Lajos 6-state model
clc 

data = xlsread('GOOG-LON_IGUS.xls');

% Size of learningData
lengthLearningData = 20;
startLearning = 2;

% Get opening price
open = data(startLearning:startLearning+lengthLearningData-1,2)';

% Get closing price
close = data(startLearning:startLearning+lengthLearningData-1,5)';

% Get intraday movement
movement = open - close;

% Create 3 observable states: [Rise, Constant, Drop]
seq = zeros(size(movement));
seq(movement<0) = 1;
seq(movement==0) = 2;
seq(movement>0) = 3;

% Initial Transition Matrix
trans = 0.02*ones(6);

for i = 1:6
    trans(i,i) = 0.9;
end

% Initial Emission Matrix
emis = 1/3*ones(6,3);

% Baum-Welch
[trans_train, emis_train] = hmmtrain(seq, trans, emis);

% Viterbi to get most probable states
probStates = hmmviterbi(seq,trans_train,emis_train);

% Get all the probabilities
prob = hmmdecode(seq,trans_train,emis_train);

state = probStates(end);

% Make prognosis


