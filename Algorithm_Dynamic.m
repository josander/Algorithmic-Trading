%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 20; % No less than 10, due to moving average
lengthLearningData = 40; % Length of learning sequences
lengthPrognosis = 40; % Nbr of days to make a prdiction about

% Set difference (delta) between two states
delta = 6;

% Starting capital
capital = 100;

%-------------------------------------------------------------------------%

% Read data
data = xlsread('GOOG-LON_IGUS.xls');

% Get openinging price
opening = data(1:820,2);

% Get closing price
closing = data(1:820,5);

% Get price movement today and tomorrow
moveToday = opening - closing;
moveTomorrow = moveToday(2:end);

% Get observable sequence for learning
seq = getObservations(moveToday, closing, delta);

% Get hidden sequenc e for learning
states = getHidden(moveTomorrow, delta);

index = 1;
trainingVector = startLearning:lengthPrognosis:length(closing)-lengthPrognosis-lengthLearningData;
firstLearningEnd = startLearning + lengthLearningData - 1;
%%
% Memory allocation

%%
for beginTraining = trainingVector
    
    % Define learning vector for later
    learningVec = beginTraining:beginTraining+lengthLearningData-1;

    % Get model parameters
    [trans, emis] = getModel(seq(learningVec), states(learningVec));

    % Get prognosis
    [pricePart, hiddenPart] = getPrognosis(seq(learningVec(1):(learningVec(end)+lengthPrognosis)),...
        lengthLearningData, trans, emis, delta, closing);

    hidden(end+1:end+length(hiddenPart)) = hiddenPart;
    price(end+1:end+length(pricePart)) = pricePart;
    index = index + length(hiddenPart);

end

% Calculate the return
endCapital = getEndingCapital(capital, opening, closing, firstLearningEnd, hidden);
%%
%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
days = firstLearningEnd+1:length(moveToday);

figure(1)
subplot(2,1,1)
plot(1:length(states), states,'b-', days, hidden(1:end-8),'r-');
legend('Actual states','Likely states');
xlabel('Day');
title('Prediction for the next day')
%%
subplot(2,1,2)
plot(1:length(closing), closing','b-', days+1, price(1:end-8),'r-');
legend('Actual closing price','Predicted closing price');
xlabel('Day');
%%
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
