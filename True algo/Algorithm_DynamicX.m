%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 20; % No less than 10
lengthLearningData = 125;
lengthProg = 5;

% Set difference (delta) between two states
delta = 5;

% Starting capital
capital = 100;

%-------------------------------------------------------------------------%

% Read data
data = xlsread('DataFiltered1.xlsx');

% Get openinging price
opening = data(1:end-1,3);

% Get closing price
closing = data(2:end,3);

% Get price movement today and tomorrow
moveToday = closing(1:end) - opening(1:end);
moveTomorrow = moveToday(2:end);

% Get observable sequence for learning
seq = getObservations(moveToday, closing, delta);

% Get hidden sequenc e for learning
states = getHidden(moveTomorrow, delta);

% Define where the last learning will begin
lastLearning = length(moveToday) - lengthProg - lengthLearningData + 1;

% Memory allocation
hidden = zeros(length(moveToday)-(startLearning+lengthLearningData-1),1);
price = zeros(length(moveToday)-(startLearning+lengthLearningData-1),1);

index = 1;

for i = startLearning:lengthProg:lastLearning
    
    disp(i)
    
    % Define learning vector for later
    learningVec = i:i+lengthLearningData-1;
    
    % Get model parameters
    [trans, emis] = getModel(seq(learningVec), states(learningVec));
    
    % Get prognosis
    [pricePart, hiddenPart] = getPrognosis(seq(learningVec(1):learningVec(end)+lengthProg), lengthLearningData, trans, emis, delta, closing(learningVec(1):learningVec(end)+lengthProg));
    
    % Save price and hidden states
    hidden(index:index+lengthProg-1) = hiddenPart;
    price(index:index+lengthProg-1) = pricePart;
    
    index = index + lengthProg;
    
end


% Check if all predictions have been made
if learningVec(end)+lengthProg ~= length(moveToday)
    
    % How many predictions are missing?
    diff = length(moveToday) - (learningVec(end)+lengthProg);
    
    % Make the predictions
    [pricePart, hiddenPart] = getPrognosis(seq(learningVec(1):learningVec(end)+lengthProg+diff), lengthLearningData, trans, emis, delta, closing(learningVec(1):learningVec(end)+lengthProg+diff));
    
    % Save price and hidden states
    hidden(index:index+diff-1) = hiddenPart(lengthProg+1:lengthProg+diff);
    price(index:index+diff-1) = pricePart(lengthProg+1:lengthProg+diff);
    
end

buy = data(1:end-1,6);
sell = data(2:end,3);

% Calculate the return
endCapital = getEndingCapital(capital, buy, sell, startLearning+lengthLearningData-1, hidden);

%---------------------------- Validation ---------------------------------%

days = startLearning+lengthLearningData:length(moveToday);
movementProg = price-closing(startLearning+lengthLearningData:end);

correctProg = ((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
    (states(startLearning+lengthLearningData:end)== 4 | states(startLearning+lengthLearningData:end)==5) == 2)...
    + ((hidden(1:end-1)==3) + (states(startLearning+lengthLearningData:end) == 3) == 2)...
    + ((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
    (states(startLearning+lengthLearningData:end)== 1 | states(startLearning+lengthLearningData:end)==2) == 2);

wrongProg = correctProg - 1;

correct = sum(correctProg);

wrong = -sum(wrongProg);

disp(['Correct',' ', 'Wrong'])
disp([correct, wrong])

% MSE
err = immse(movementProg(1:end-1),moveToday(startLearning+lengthLearningData+1:end));

disp('Mean squared error:')
disp(err)

disp('Ending capital')
disp(endCapital(end))

%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
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
plot(days+1,movementProg,1:length(moveToday), moveToday')
legend('Predicted movement','Actual movement')

figure(4)
subplot(3,1,1)
plot(days+1,cumsum(movementProg)+opening(days(1)),1:length(closing),closing)
legend('Cumulated movement','Closing price')
title('Price of asset')

subplot(3,1,2)
plot(days, endCapital, [1 days(end)], [capital capital])
title('Capital')

subplot(3,1,3)
plot(days(1:end-1), cumsum(correctProg+wrongProg), [1 days(end)], [0 0])
title('Cumulations of correct and wrong number of predictions')

%% For evalutaion

disp([(correctProg+wrongProg) endCapital(2:end)-1 hidden(1:end-1) states(startLearning+lengthLearningData:end) moveToday(startLearning+lengthLearningData+1:end)])
