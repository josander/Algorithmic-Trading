function [ price ] = getPrice( likelyStates, delta, closing, endLearning )

    closeNew = closing(endLearning+1:end);

    price(likelyStates == 1) = closeNew(likelyStates == 1) - delta;
    price(likelyStates == 2) = closeNew(likelyStates == 2) + delta;

end

