function [ price ] = getPrice( likelyStates, delta, closing, endLearning )

    closeNew = closing(endLearning+1:end);

    price(likelyStates == 1) = closeNew(likelyStates == 1) - 4*delta;
    price(likelyStates == 2) = closeNew(likelyStates == 2) - 2*delta;
    price(likelyStates == 3) = closeNew(likelyStates == 3) + 0;
    price(likelyStates == 4) = closeNew(likelyStates == 4) + 2*delta;
    price(likelyStates == 5) = closeNew(likelyStates == 5) + 4*delta;

end

