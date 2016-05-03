%% Test HMM functions of real data
clc
clear all
clf

data = xlsread('GOOG-LON_IGUS.xls',1);

startLearning = 15;
lengthLearningData = 45;

% Get opening price
open = data(startLearning:startLearning+lengthLearningData,2)';

% Get closing price
close = data(startLearning:startLearning+lengthLearningData,5)';

% Get intraday movement
movement = data(:,2) - data(:,5);
moveToday = open(1:end-1) - close(1:end-1);
moveTomorrow = open(2:end) - close(2:end);

% Create 3 observable states: [Rise, Constant, Drop]
seq = zeros(size(moveToday));
seq(moveToday<0) = 1;
seq(moveToday==0) = 2;
seq(moveToday>0) = 3;

% Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
delta = 5;
a = -delta;
b = delta;

% Create state-matrix [5x5]
states = zeros(size(moveTomorrow));
states(moveTomorrow < 3*a) = 1;
states(moveTomorrow >= 3*a & moveTomorrow < a) = 2;
states(moveTomorrow >= a & moveTomorrow < b) = 3;
states(moveTomorrow >= b & moveTomorrow < 3*b) = 4;
states(moveTomorrow >= 3*b ) = 5;

% ESTIMATE MATRICES
% Get estimate of transition and emision matrix
[trans_est, emis_est] = hmmestimate(seq, states);

% TRAIN THE HMM
% Specify maximal number of iterations. Default is 500
maxiter = 1000;

% Estimate the two matrices
[trans_train, emis_train] = hmmtrain(seq, trans_est, emis_est,'maxiterations',maxiter);

DayVec = 3+lengthLearningData+startLearning:size(data,1);
days = zeros(size(DayVec));
plotStates = zeros(size(DayVec));
plotLikelyStates = zeros(size(DayVec));
plotClose = zeros(size(DayVec));
plotCloseProg = zeros(size(DayVec));
progMovement = zeros(size(DayVec));

% PROGNOSIS
for nextDay = DayVec

    % Get opening price
    openNew = data(nextDay,2)';

    % Get closing price
    closeNew = data(nextDay,5)';

    % Get past movement
    movementNew = openNew - closeNew;

    % Create 3 observable states: [Rise, Constant, Drop]
    seqNew = zeros(size(movementNew));
    seqNew(movementNew<0) = 1;
    seqNew(movementNew==0) = 2;
    seqNew(movementNew>0) = 3;

    % Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
    % Create state-matrix [5x5]
    statesNew = zeros(size(movementNew));
    statesNew(movementNew < 3*a) = 1;
    statesNew(movementNew >= 3*a & movementNew < a) = 2;
    statesNew(movementNew >= a & movementNew < b) = 3;
    statesNew(movementNew >= b & movementNew < 3*b) = 4;
    statesNew(movementNew >= 3*b ) = 5;

    % Use Viterbi to estimate most probable state sequence
    likelystatesNew = hmmviterbi(seqNew, trans_train, emis_train);

    close_prog(likelystatesNew == 1) = openNew(likelystatesNew == 1) + 4*a;
    close_prog(likelystatesNew == 2) = openNew(likelystatesNew == 2) + 2*a;
    close_prog(likelystatesNew == 3) = openNew(likelystatesNew == 3) + 0;
    close_prog(likelystatesNew == 4) = openNew(likelystatesNew == 4) + 2*b;
    close_prog(likelystatesNew == 5) = openNew(likelystatesNew == 5) + 4*b;
    
    moveProg(likelystatesNew == 1) = 4*a;
    moveProg(likelystatesNew == 2) = 2*a;
    moveProg(likelystatesNew == 3) = 0;
    moveProg(likelystatesNew == 4) = 2*b;
    moveProg(likelystatesNew == 5) = 4*b;
    
    index = nextDay - (3+lengthLearningData+startLearning)+1;
    days(index) = nextDay;
    plotStates(index) = statesNew;
    plotLikelyStates(index) = likelystatesNew;
    plotClose(index) = closeNew;
    plotCloseProg(index) = close_prog;
    progMovement(index) = moveProg;
    
end

figure(1)
subplot(2,1,1)
plot(days, plotStates,'b-', days, plotLikelyStates,'r-');
legend('Actual states','Likely states');

subplot(2,1,2)
plot(days, plotClose,'b-', days, plotCloseProg,'r-');
legend('Actual closing price','Predicted closing price');

figure(2)
subplot(3,1,1)
hist(seq)
title('Seq')
subplot(3,1,2)
hist(states)
title('States')
subplot(3,1,3)
hist(plotLikelyStates)
title('Likely states')

figure(3)
plot(days,progMovement,1:length(data), movement)
legend('Predicted movement','Actual movement')

figure(4)
plot(days,cumsum(progMovement)+data(days(1),2),1:length(data),data(:,5))
legend('Cumulated movement','Closing price')

correct = sum((progMovement > 0 & movement(end-length(progMovement):end-1)' > 0) | (progMovement < 0 & movement(end-length(progMovement):end-1)' < 0));
wrong = length(progMovement) - correct;

disp(['Correct',' ', 'Wrong'])
disp([correct, wrong])

% MSE
err = immse(plotClose,plotCloseProg)


