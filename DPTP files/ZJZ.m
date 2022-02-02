classdef ZJZ < DYNAMIC_PROBLEM
    %% ZJZ
    %Zhou, A., Jin, Y., Zhang, Q., Sendhoff, B., & Tsang, E. (2007). Prediction-Based Population 
    %Re-initialization for Evolutionary Dynamic Multi-objective Optimization. 
    %Proceedings of EMO,LNCS4403, 832–846. https://doi.org/10.1007/978-3-540-70928-2_62
        
    % Type I
    % Minimize f1=f1(xi); f2=g(xii,t)*h(f1,g);
    % xi,xii range [0,1]
    
    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = ZJZ(varargin)
        %% Overloaded Constructor
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 -1];
            thisProblem.upperDecBound=[1 2];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else 
                thisProblem.DecVarsSplit=[1 thisProblem.DecVars-1]; 
            end
            
            thisProblem.PF=ParetoFront(thisProblem,100);
            
        end
        
        

        
        %%
        function popObj = CalcObj(thisProblem,PopulationDecVars,t)
            %popObj is a N*M matrix of objective values
            if nargin<3 
                t=thisProblem.t_val;
            end
            xsplit=[];
            for i=1:length(thisProblem.DecVarsSplit)
                if i==1
                    xsplit=[1 thisProblem.DecVarsSplit(1)];
                else
                    xsplit=[xsplit; xsplit(i-1,2)+1 xsplit(i-1,2)+thisProblem.DecVarsSplit(i)];
                end
            end
            

            xi=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
            xii=PopulationDecVars(:,xsplit(2,1):xsplit(2,2));
            
            f1=xi;
            G=sin(0.5*pi*t);
            H=0.75*sin(0.5*pi*t)+1.25;
            g=1+(sum((xii-G-(xi.^H)).^2,2));
            h=1-((f1./g).^H);
            f2=g.*h;

            
            popObj=[f1 f2];

            
        end
        %%
        function popCon = CalcCon(thisProblem,PopulationDecVars)
            popCon=zeros(size(PopulationDecVars));
        end
        
        %% Sample reference points on Pareto front
        function P = ParetoFront(thisProblem,N)

            xi = linspace(0,1,N)';
            H=0.75*sin(0.5*pi*thisProblem.t_val)+1.25;

            P=xi;
            P=[P (1-(xi.^(H)))];
            % xi range [0,1]
            % xii range [-1,2]
            % POS=G+(xi^H) / POF=(1-(f1.^(H)))
            % G=sin(0.5*pi*t); f1=xi;
        end
    end
    
end
