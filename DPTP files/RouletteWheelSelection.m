function index = RouletteWheelSelection(N,Fitness)
% Modififed by ----- ----- for DPTP 2021

% This function is borrowed directly from PlatEMO, it is well written and
% therefore required no modification other than ensuring the inputs were of
% the correct format. We acknowledge the core principle implemented in "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87". The original
% blurb is as below.



%RouletteWheelSelection - Roulette-wheel selection.
%
%   P = RouletteWheelSelection(N,fitness) returns the indices of N
%   solutions by roulette-wheel selection based on fitness. A SMALLER
%   fitness value indicates a LARGER probability to be selected.
%
%   Example:
%       P = RouletteWheelSelection(100,FrontNo)

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    Fitness = reshape(Fitness,1,[]);
    Fitness = Fitness + min(min(Fitness),0);
    Fitness = cumsum(1./Fitness);
    Fitness = Fitness./max(Fitness);
    index   = arrayfun(@(S)find(rand<=Fitness,1),1:N);
end