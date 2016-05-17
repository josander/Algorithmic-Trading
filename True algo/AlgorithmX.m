%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 10; % No less than 10
lengthLearningData = 150;

% Chose data set
dataset = 2;

% Set difference (delta) between two states
delta = 2;

% Starting capital
capital = 100;

%-------------------------------------------------------------------------%

% Filename
file = 'DataFiltered1.xlsx';

% Read data
data = xlsread(file);

first = [1 453];
last = [370 822];

% Get openinging price
opening = data(first(dataset):last(dataset)-1,3);

% Get closing price
closing = data(first(dataset)+1:last(dataset),3);

% Get price movement today and tomorrow
moveToday = closing - opening;
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

buy = data(1:end-1,6);
sell = data(2:end,3);

% Calculate the return
[endCapital, index] = getEndingCapital(capital, buy, sell, learningVec(end), hidden);

%---------------------------- Validation ---------------------------------%

days = learningVec(end)+1:length(moveToday);
movementProg = price-closing(learningVec(end)+1:end)';

correctProg = ((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
    (states(learningVec(end)+1:end)== 4 | states(learningVec(end)+1:end)==5) == 2)...
    + ((hidden(1:end-1)==3) + (states(learningVec(end)+1:end) == 3) == 2)...
    + ((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
    (states(learningVec(end)+1:end)== 1 | states(learningVec(end)+1:end)==2) == 2);

wrongProg = correctProg - 1;

correct = sum(correctProg);

wrong = -sum(wrongProg);

disp(['Correct',' ', 'Wrong'])
disp([correct, wrong])

% MSE
err = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');

disp('Mean squared error:')
disp(err)

disp('Ending capital')
disp(endCapital(end))

disp('Index')
disp(index(end))

disp('Ratio [%]')
disp(correct/(correct+wrong)*100)

%% For evalutaion

disp([(correctProg+wrongProg) endCapital(2:end) index(2:end) hidden(1:end-1) states(learningVec(end)+1:end) moveToday(learningVec(end)+2:end)])

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
title('Prediction with static learning model','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(2)
subplot(1,1,1)
plot(days+1,cumsum(movementProg)+opening(days(1)),'b',1:length(closing),closing,'r')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('Price [SEK]','Interpreter','latex', 'fontsize', 18);
h_legend = legend('Cumulated movement','Actual closing price');
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Prediction with static learning model','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(3)
subplot(1,1,1)
plot(days, endCapital,'b',days, index,'r', [1 days(end)], [capital capital],'k')
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
title('Cumulations of correct and wrong number of predictions','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])


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