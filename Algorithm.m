%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 15; % No less than 10
lengthLearningData = 40; % 45 is best but then we get a row with zeros in the emision matrix

% Set difference (delta) between two states
delta = 6;

% Starting capital
capital = 100;

%-------------------------------------------------------------------------%

% Read data
data = xlsread('GOOG-LON_IGUS.xls');

% Get openinging price
opening = data(:,2);

% Get closing price
closing = data(:,5);

% Get price movement today and tomorrow
moveToday = opening(1:end) - closing(1:end);
moveTomorrow = moveToday(2:end);

% Define learning vector for later
learningVec = startLearning:startLearning+lengthLearningData-1;

% Get observable sequence for learning
seq = getObservations(moveToday, closing, delta);

% Get hidden sequenc e for learning
states = getHidden(moveTomorrow, delta);

% Get model parameters
[trans, emis] = getModel(seq(learningVec), states(learningVec));

% Get prognosis
[price, hidden] = getPrognosis(seq, learningVec(end), trans, emis, delta, closing);

% Calculate the return
endCapital = getEndingCapital(capital, opening, closing, learningVec(end), hidden);

%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
days = learningVec(end)+1:length(moveToday);
figure(1)
subplot(2,1,1)
plot(1:length(states), states,'b-', days, hidden,'r-');
legend('Actual states','Likely states');
xlabel('Day');
title('Prediction for the next day')

subplot(2,1,2)
plot(1:length(closing), closing','b-', days+1, price,'r-');
legend('Actual closing price','Predicted closing price');
xlabel('Day');

figure(2)
subplot(3,1,1)
hist(seq)
title('Histogram of observations');
subplot(3,1,2)
hist(states);
title('Histogram of hidden states')
subplot(3,1,3)
hist(hidden);
title('Predicted hidden states')

figure(3)
movementProg = price-closing(learningVec(end)+1:end)';
plot(days+1,movementProg,1:length(moveToday), moveToday')
legend('Predicted movement','Actual movement')

figure(4)
subplot(2,1,1)
plot(days+1,cumsum(movementProg)+opening(days(1)),1:length(closing),closing)
legend('Cumulated movement','Closing price')
title('Price of asset')

subplot(2,1,2)
plot(days, endCapital, [1 days(end)], [capital capital])
title('Capital')

%---------------------------- Validation ---------------------------------%

correct = sum((movementProg(1:end-1) > 0 & moveToday(learningVec(end)+2:end)' > 0) | ...
    (movementProg(1:end-1) < 0 & moveToday(learningVec(end)+2:end)' < 0) | ...
    (movementProg(1:end-1) == 0 & moveToday(learningVec(end)+2:end)' == 0));
wrong = length(movementProg(1:end-1)) - correct;

disp(['Correct',' ', 'Wrong'])
disp([correct, wrong])

% MSE
err = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');

disp('Mean squared error:')
disp(err)

disp('Ending capital')
disp(endCapital(end))
