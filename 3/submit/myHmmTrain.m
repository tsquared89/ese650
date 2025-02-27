function [A,b] = myHmmTrain(seqs,guessA,guessb)
% [A,b] = hmmtrain(seqs,guessA,guessb)
% Trains an HMM based on the sequences passed in.
A =guessA;
b = guessb;
Anew = A;
bNew = b;
thresh = 0.01;
stoppingCondition = false;
%i = 0;
while ~ stoppingCondition
    %i = i+1
    bNew = zeros(size(bNew));
    Anew = zeros(size(Anew));
    for i=1:numel(seqs)
        [bb, AA] = BWSingleSeq(seqs{i}, A, b);
        bNew = bNew + bb;
        Anew = Anew + AA;
    end
    % normalize:
    Anew = bsxfun(@rdivide, Anew, sum(Anew, 2));
    bNew = bsxfun(@rdivide, bNew, sum(bNew, 2));
    stoppingCondition = (norm(Anew-A,'fro')/norm(A,'fro') < thresh) && ...
                   (norm(bNew-b,'fro')/norm(b,'fro') < thresh); % && ...
                   %((logProbNew - logProb)/logProb < thresh);
    A = Anew;
    b = bNew;
end
return
end

% function [conditionMet] = testStoppingCondition()
%     conditionMet = (norm(Anew-A,'fro')/norm(A,'fro') < thresh) && ...
%                    (norm(bNew-b,'fro')/norm(b,'fro') < thresh) && ...
%                    ((logProbNew - logProb)/logProb < thresh);
% end

function [bb, AA] = BWSingleSeq(seq, A, b)
    AA = A;
    bb = b;
    numSymbols = size(b,2);
    numStates = size(A,2);
    [stateEstimate, sequenceLogProb, logAlpha, logBeta] = myHmmDecode( seq, A, b );
    stateEstimate = stateEstimate';
    for state=1:numStates
        for symbol = 1:numSymbols
            occurrences = (seq == symbol) & (stateEstimate == state);
            bb(state, symbol) = sum(occurrences);
        end
    end
    % estimate transitions
    for prev = 1:numStates
        for next = 1:numStates
            prevState = (stateEstimate == prev);
            nextState = (stateEstimate == next);
            transitions = ( prevState & [nextState(2:end), 0] );
            AA(prev, next) = sum(transitions);
        end
    end
end