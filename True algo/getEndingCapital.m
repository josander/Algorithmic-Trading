function [ endCapital, indexReturn, returnHMM, returnLong] = getEndingCapital( startCapital, opening, closing, learningEnd, hidden )

capital = startCapital;
endCapital = zeros(length(hidden),1);
indexReturn = zeros(length(hidden),1);
returnHMM = zeros(length(hidden),1);
returnLong = zeros(length(hidden),1);
endCapital(1) = startCapital;
indexCapital = startCapital;
indexReturn(1) = startCapital;

for i = 1:length(hidden)-1

    % What position should be taken?
    switch hidden(i)

        case 1 % Negative predicted movement(i+1) -> take short position

            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (-dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            indexCapital = (dailyReturn + 1) * indexCapital;
            indexReturn(i+1) = indexCapital;
            returnLong(i+1) = dailyReturn;            
            returnHMM(i+1) = - dailyReturn;

%         case 2 % Negative predicted movement(i+1) -> take short position
% 
%             dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
%             capital = (-dailyReturn + 1) * capital;
%             endCapital(i+1) = capital;
%             indexCapital = (dailyReturn + 1) * indexCapital;
%             indexReturn(i+1) = indexCapital;
%             returnLong(i+1) = dailyReturn;
%             returnHMM(i+1) = - dailyReturn;

        case 2 % Predicted movement(i+1) equals zero -> Do nothing

            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            endCapital(i+1) = capital;
            indexCapital = (dailyReturn + 1) * indexCapital;
            indexReturn(i+1) = indexCapital;
            returnLong(i+1) = dailyReturn;
            returnHMM(i+1) = 0;

        case 4 % Positive predicted movement(i+1) -> take long position

            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            indexCapital = (dailyReturn + 1) * indexCapital;
            indexReturn(i+1) = indexCapital;
            returnLong(i+1) = dailyReturn;
            returnHMM(i+1) = dailyReturn;

        case 3 % Positive predicted movement(i+1) -> take long position

            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            indexCapital = (dailyReturn + 1) * indexCapital;
            indexReturn(i+1) = indexCapital;
            returnLong(i+1) = dailyReturn;
            returnHMM(i+1) = dailyReturn;

    end

end


end

