function [ price ] = getPrice( likelyStates, delta, open, lengthLearning )

    openNew = open(lengthLearning+2:end);

    price = zeros(size(likelyStates));
    price(likelyStates == 1) = openNew(likelyStates == 1) - 4*delta;
    price(likelyStates == 2) = openNew(likelyStates == 2) - 2*delta;
    price(likelyStates == 3) = openNew(likelyStates == 3) + 0;
    price(likelyStates == 4) = openNew(likelyStates == 4) + 2*delta;
    price(likelyStates == 5) = openNew(likelyStates == 5) + 4*delta;

end

