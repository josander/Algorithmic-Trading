%% Test HMM functions of real data
clc
clear all
clf

data = xlsread('GOOG-LON_IGUS.xls',1);

startLearning = 15; % No less than 10
lengthLearningData = 45;
learningVec = startLearning:startLearning+lengthLearningData;
delta = 6;

% Get openinging price
opening = data(startLearning:startLearning+lengthLearningData,2)';

% Get closing price
closing = data(startLearning:startLearning+lengthLearningData,5)';

% Get intraday movement: openinging price - closing price
movement = data(:,2) - data(:,5);
moveTomorrow = movement(2:end);

% Get moving average
movAver = tsmovavg(data(:,5),'s',10,1);

% Difference in closing price and 10-value moving average
meanReversion = data(:,5) - movAver;
meanRev(meanReversion > delta) = 1;
meanRev(meanReversion <= delta & meanReversion >= -delta) = 2;
meanRev(meanReversion < -delta) = 3;

mov(movement>delta) = 1;
mov(movement<= delta & movement >= -delta) = 2;
mov(movement<-delta) = 3;

% Create 3 observable states: [Rise, Constant, Drop]
seq = zeros(size(movement));
seq(mov == 1 & meanRev == 1) = 1;
seq(mov == 1 & meanRev == 2) = 2;
seq(mov == 1 & meanRev == 3) = 3;
seq(mov == 2 & meanRev == 1) = 4;
seq(mov == 2 & meanRev == 2) = 5;
seq(mov == 2 & meanRev == 3) = 6;
seq(mov == 3 & meanRev == 1) = 7;
seq(mov == 3 & meanRev == 2) = 8;
seq(mov == 3 & meanRev == 3) = 9;


% Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
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
[trans_est, emis_est] = hmmestimate(seq(learningVec), states(learningVec));

% TRAIN THE HMM
% Specify maximal number of iterations. Default is 500
maxiter = 1000;
tol = 1e-4;

% Estimate the two matrices
[trans_train, emis_train] = hmmtrain(seq(learningVec), trans_est, emis_est,'maxiterations',maxiter,'Tolerance',tol);

DayVec = 3+lengthLearningData+startLearning:size(data,1);
days = zeros(size(DayVec));
plotStates = zeros(size(DayVec));
plotLikelyStates = zeros(size(DayVec));
plotclosing = zeros(size(DayVec));
plotclosingProg = zeros(size(DayVec));

% PROGNOSIS
for nextDay = DayVec

    % Use Viterbi to estimate most probable state sequence
    likelyState = hmmviterbi(seq(nextDay), trans_train, emis_train);

    closingNew = data(nextDay,5);
    
    closing_prog(likelyState == 1) = closingNew(likelyState == 1) + 4*a;
    closing_prog(likelyState == 2) = closingNew(likelyState == 2) + 2*a;
    closing_prog(likelyState == 3) = closingNew(likelyState == 3) + 0;
    closing_prog(likelyState == 4) = closingNew(likelyState == 4) + 2*b;
    closing_prog(likelyState == 5) = closingNew(likelyState == 5) + 4*b;
    
    moveProg(likelyState == 1) = 4*a;
    moveProg(likelyState == 2) = 2*a;
    moveProg(likelyState == 3) = 0;
    moveProg(likelyState == 4) = 2*b;
    moveProg(likelyState == 5) = 4*b;
    
    index = nextDay - (3+lengthLearningData+startLearning)+1;
    days(index) = nextDay;
    plotLikelyStates(index) = likelyState;
    plotclosingProg(index) = closing_prog;
    progMovement(index) = moveProg;
    
end

figure(1)
subplot(2,1,1)
plot(1:length(data)-1, states,'b-', days, plotLikelyStates,'r-');
legend('Actual states','Likely states');

subplot(2,1,2)
plot(1:length(data), data(:,5),'b-', days, plotclosingProg,'r-');
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
err = immse(plotclosing,plotclosingProg)


