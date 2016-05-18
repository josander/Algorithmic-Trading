function [hidden] = getHidden(movementTomorrow, delta)
% From a movement vector, the hidden sequence will be computed and
% returned. The hidden states are defined as the price movement the
% following day. 
%
% Arguments:
% movement          Vector of proce movements on the stock market.
% lengthLearning    Length of the training data wanted
% nbrStates         Nuber of hidden states wanted


% Create hidden state sequence
hidden = zeros(length(movementTomorrow), 1);

% Seven states
% hidden(movementTomorrow < -5*delta) = 1;
% hidden(movementTomorrow >= -5*delta & movementTomorrow < -3*delta) = 2;
% hidden(movementTomorrow >= -3*delta & movementTomorrow < -delta) = 3;
% hidden(movementTomorrow >= -delta & movementTomorrow < delta) = 4;
% hidden(movementTomorrow >= delta & movementTomorrow < 3*delta) = 5;
% hidden(movementTomorrow >= 3*delta & movementTomorrow < 5*delta) = 6;
% hidden(movementTomorrow >= 5*delta ) = 7;

% Five states
% hidden(movementTomorrow < -3*delta) = 1;
% hidden(movementTomorrow >= -3*delta & movementTomorrow < -delta) = 2;
% hidden(movementTomorrow >= -delta & movementTomorrow < delta) = 3;
% hidden(movementTomorrow >= delta & movementTomorrow < 3*delta) = 4;
% hidden(movementTomorrow >= 3*delta ) = 5;

% Three states
% hidden(movementTomorrow < -delta) = 1;
% hidden(movementTomorrow >= -delta & movementTomorrow < delta) = 2;
% hidden(movementTomorrow >= delta) = 3;

% Two states
hidden(movementTomorrow < 0) = 1;
hidden(movementTomorrow >= 0) = 2;

end

