%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

clf

% To develope:
% Generalize how many states that are possible
% Dynamic learning
% Snygga till delta-definitionen!!!

% Length of learning data
lengthLearningData = 80;

% Number of observable states
nbrObsStates = 3;

% Number of hidden states
nbrHiddenStates = 6;

%-------------------------------------------------------------------------%

% Read data
data = xlsread('WIKI-FLWS.xls');

% Get opening price
open = data(2:end,2)';

% Get closing price
close = data(2:end,5)';

% Get price movement
movement= close - open;

% Get difference (delta) between two states
biggestChange = max(movement) - min(movement);
delta = biggestChange/10;

% Get observable sequence for learning
seq = getObservations(movement,lengthLearningData, delta);

% Get hidden sequence for learning
states = getHidden(movement,lengthLearningData, delta);

% Get model parameters
[trans, emis] = getModel(seq, states);

% Get prognosis
price = getPrognosis(movement,lengthLearningData, trans, emis, delta, open);

% Plot the true and forecasted price
figure(1)
days = lengthLearningData+3:length(movement)-1;
plot(days,price(2:end),days, open(lengthLearningData+3:end-1),days, close(lengthLearningData+3:end-1));
legend('Prognosis', 'Open', 'Close');
xlabel('Days');
ylabel('Stock price [SEK]');

figure(2)
movementProg = price(2:end) - price(1:end-1);
movementClose = close(2:end)-close(1:end-1);
plot(1:length(movementClose),movementClose,days,movementProg)
legend('Predicted movement','Real movement');
xlabel('Days');
ylabel('Price movement [SEK]');

err = mse(movementProg,movementClose);
disp(err)