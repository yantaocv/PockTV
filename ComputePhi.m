function [ Phi, E ] = ComputePhi( PhiInit, PInit, Input, LabelQuantification,  StepD, StepP )
%Run the algorithm from an initialization to the resulting phi.

    DefaultStepP = 1/sqrt(3);
    DefaultStepD = 1/sqrt(3);
    
    maxIter = 30;

    %Check Inputs.
    fprintf('Arguments sanity check...');
    if (nargin < 6)
        StepP = DefaultStepP;
    end
    if (nargin < 5)
        StepD = DefaultStepD;
    end

    if (StepP * StepD > 1/3 + 0.00001)
        warning('StepP * StepD = %d. Convergence is not guaranteed (should be < 1/3).', StepP * StepD);
    end

    [h, w ,k] = size(PhiInit);
    if (w == 1||h == 1||k == 1)
        error('PhiInit should be a 3D matrix (Height x Width x (Vmax - Vmin + 2)).');
    end
    
    [h2,w2,k2,s] = size(PInit);
    if (w2 == 1||h2 == 1||k2 == 1||s ~= 3)
        error('PInit should be a 4D matrix (Height x Width x (Vmax - Vmin + 2) x 3).');
    end
    
    if (w ~= w2||h ~= h2||k ~= k2)
        error('First 3 dimensions of PhiInit and PInit should match.');
    end
    disp ('Done.');
    
    fprintf('Using:\nStepP = %d\n', StepP);
    fprintf('StepD = %d\n\n', StepD);
    
    PhiK = zeros(size(PhiInit));
    PhiKPlus1 = PhiInit;
    PKPlus1 = PInit;
    
    disp('Starting to iterate...');
    numIter = 0;
    while (numIter < maxIter)
        numIter = numIter + 1;
        Img = ConstructImageFromPhi(PhiKPlus1, LabelQuantification);
        if (mod(numIter, 200) == 0)
            mat2imw9(uint16(Img), 'iter');
        end
        E(numIter) = ComputeEnergy(Input, Img, LabelQuantification);
        if (numIter > 25 && E(numIter - 1) < E(numIter))
            PhiKPlus1 = PhiK;
            break;
        end
        fprintf('Iter #%i, Changed = %d, Energy = %d\n', numIter, sum(sum(sum(abs(PhiKPlus1 - PhiK)))), E(numIter));
        PhiK = PhiKPlus1;
        PK = PKPlus1;
        
        [PhiKPlus1, PKPlus1] = Iterate(PhiK, PK, StepP, StepD, Input, LabelQuantification);
    end
    disp('Solution found!');
    
    Phi = PhiKPlus1;
    
end

