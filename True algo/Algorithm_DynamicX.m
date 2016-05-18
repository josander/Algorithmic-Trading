%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 10; % No less than 10
lengthLearningData = 150;
lengthProg = 1;

dataset = 2;

% Set difference (delta) between two states
delta = 2;

% Starting capital
capital = 100;

%-------------------------------------------------------------------------%

% Read data
data = xlsread('DataFiltered1.xlsx');

first = [1 453];
last = [370 822];

% Get openinging price
opening = data(first(dataset):last(dataset)-1,3);

% Get closing price
closing = data(first(dataset)+1:last(dataset),3);

% Get price movement today and tomorrow
moveToday = closing(1:end) - opening(1:end);
moveTomorrow = moveToday(2:end);

% Get observable sequence for learning
seq = getObservations(moveToday, closing, delta);

% Get hidden sequence for learning
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

buy = data(first(dataset):last(dataset)-1,6);
sell = data(first(dataset)+1:last(dataset),3);

% Calculate the return
[endCapital, indexReturn, returnHMM, returnIndex, priceChange] = getEndingCapital(capital, buy, sell, startLearning+lengthLearningData-1, hidden);

%---------------------------- Validation ---------------------------------%

days = startLearning+lengthLearningData:length(moveToday);
movementProg = price-closing(startLearning+lengthLearningData:end);

% correctProg = ((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
%     (states(startLearning+lengthLearningData:end)== 4 | states(startLearning+lengthLearningData:end)==5) == 2)...
%     + ((hidden(1:end-1)==3) + (states(startLearning+lengthLearningData:end) == 3) == 2)...
%     + ((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
%     (states(startLearning+lengthLearningData:end)== 1 | states(startLearning+lengthLearningData:end)==2) == 2);

correctProg = (hidden(1:end-1)==states(startLearning+lengthLearningData:end));


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

disp('Ratio')
disp(correct/(correct+wrong)*100)

%%
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


%%
%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
figure(1);
subplot(1,1,1)
plot(1:length(closing), closing','b-', days+1, price,'r-');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('Price [SEK]','Interpreter','latex', 'fontsize', 18);
h_legend = legend('Actual closing price','Predicted closing price');
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Prediction with dynamic learning model','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(2)
subplot(1,1,1)
plot(days,cumsum(movementProg)+opening(days(1)),'b',1:length(closing),closing,'r')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('Price [SEK]','Interpreter','latex', 'fontsize', 18);
h_legend = legend('Cumulated movement','Actual closing price');
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Cumulated movement in price','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(3)
subplot(1,1,1)
plot(days, endCapital,'b',days, indexReturn,'r', [1 days(end)], [capital capital], 'k')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('Capital [SEK]','Interpreter','latex', 'fontsize', 18);
h_legend = legend('Change in capital with HMM','Index movement');
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Change in capital','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(4)
subplot(1,1,1)
plot(days(1:end-1), cumsum(correctProg+wrongProg),'b', [1 days(end)], [0 0],'k')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('[-]','Interpreter','latex', 'fontsize', 18);
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Cumulated correct and wrong number of predictions','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])


%% 

%----------------------- Evalutaion of algorithm -------------------------%

disp(['Corr/wrong',' ','CapitalHMM',' ','CapitalIndex',' ','RetHMM',' ','RetIndex','   ', 'PredState', '   ' ,'ActState', ' ','Movement', ' ', 'Day'])
disp([(correctProg+wrongProg) endCapital(2:end) indexReturn(2:end) returnHMM(2:end) returnIndex(2:end) hidden(1:end-1) states(startLearning+lengthLearningData:end) moveToday(startLearning+lengthLearningData+1:end) days(2:end)'])

SharpeRatio = sharpe(returnHMM(2:end), returnIndex(2:end));

disp(SharpeRatio*100)
