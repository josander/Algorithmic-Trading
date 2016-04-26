function [hidden] = getHidden(movement, lengthLearning, delta)
% From a movement vector, the hidden sequence will be computed and
% returned. The hidden states are defined as the price movement the
% following day. 
%
% Arguments:
% movement          Vector of proce movements on the stock market.
% lengthLearning    Length of the training data wanted
% nbrStates         Nuber of hidden states wanted


% Create hidden state sequence
hidden = zeros(lengthLearning, 1);
hidden(movement(2:lengthLearning+1) < -3*delta) = 1;
hidden(movement(2:lengthLearning+1) >= -3*delta & movement(2:lengthLearning+1) < -delta) = 2;
hidden(movement(2:lengthLearning+1) >= -delta & movement(2:lengthLearning+1) < delta) = 3;
hidden(movement(2:lengthLearning+1) >= delta & movement(2:lengthLearning+1) < 3*delta) = 4;
hidden(movement(2:lengthLearning+1) >= 3*delta ) = 5;

end