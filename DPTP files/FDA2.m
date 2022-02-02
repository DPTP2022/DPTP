classdef FDA2 < DYNAMIC_PROBLEM
    %Farina, M., Deb, K., & Amato, P. (2003). Dynamic Multiobjective Optimization Problems: 
    %Test Cases Approximation and Applications. Evolutionary Multi-Criterion Optimization. 
    %Second International Conference EMO 2003, 8(5), 311–326. 
    %https://doi.org/10.1109/TEVC.2004.831456
    
    
    properties
        PF=[];
        DecVarsSplit;
    end
    methods
        function thisProblem = FDA2(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 -1 -1];
            thisProblem.upperDecBound=[1 1 1];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else 
                thisProblem.DecVarsSplit=[1 floor((thisProblem.DecVars-1)/2) ceil((thisProblem.DecVars-1)/2)]; %VERIFY/JUSTIFY THESE NUMBERS
            end
            
            thisProblem.PF=ParetoFront(thisProblem,100);
            
        end
        
        

        
        %%
        function popObj = CalcObj(thisProblem,PopulationDecVars,t)
            %popObj is a N*M matrix of objective values
            if nargin<3 %t can be specified on the call of the function (DEBUGGING)
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
            
            
            
            %% FARINA 2003
            %-1-% For testing
%             Npop=25;
%             xpop=[linspace(0,1,Npop)' zeros(Npop,1) -ones(Npop,1)];
%             PopulationDecVars=xpop;
            
            %Farina 2003 version
            f1=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
            g=1+sum(PopulationDecVars(:,xsplit(2,1):xsplit(2,2)).^2,2);
            H=0.75+(0.7*sin(0.5*pi*t));
            h=1-((f1./g).^(1./(H+sum((PopulationDecVars(:,xsplit(3,1):xsplit(3,2))-H).^2,2))));
            f2=g.*h;
            
            %PF
            plot(0:0.01:1,(1-((0:0.01:1).^(1/(H+thisProblem.DecVarsSplit(3)*((H).^2))))),'b--'); 
%             hold on; scatter(f1,f2,150,'k.'); axis square;
%             hold off;
            %-1-% For testing
%             hold on; scatter(f1,f2,150,'k.'); axis square; title(['Farina t=' num2str(t)]); hold off;
%             xlabel('f_1'); ylabel('gh')
%             print(gcf,['PFFarina_t=' num2str(t) '.png'],'-dpng','-r1200')

            %% Alternative Versions
%             %% jMetal version
%             Npop=15;
%             xpop=[linspace(0,1,Npop)' zeros(Npop,1) zeros(Npop,1)];
%             PopulationDecVars=xpop;
%             
%             %jMetal 2018 version
%             f1=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
%             g=1+sum(PopulationDecVars(:,xsplit(2,1):xsplit(2,2)).^2,2)...
%                     +sum((1+PopulationDecVars(:,xsplit(3,1):xsplit(3,2))).^2,2);
%             HT=0.2+4.8*(t^2);
%             h=1-((f1./g).^HT);
%             f2=g.*h;
%             
%             %PF
%             plot(0:0.01:1,(1-sqrt(0:0.01:1)),'b--'); %jMetal - given as comment
%             hold on; scatter(f1,f2,150,'k.'); axis square; title(['jMetal t=' num2str(t)]); hold off;
%             xlabel('f_1'); ylabel('gh')
%             print(gcf,['PFjMetal_t=' num2str(t) '.png'],'-dpng','-r1200')
% 
%             
%             %% Shang2014
%             Npop=15;
%             xpop=[linspace(0,1,Npop)' zeros(Npop,1) zeros(Npop,1)];
%             PopulationDecVars=xpop;
%             
%             %Shang 2014 version
%             f1=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
%             g=1+sum(PopulationDecVars(:,xsplit(2,1):xsplit(2,2)).^2,2);
%             H=0.75+(0.7*sin(0.5*pi*t));
%             h=1-((f1./g).^(H+sum((PopulationDecVars(:,xsplit(3,1):xsplit(3,2))-H).^2,2)));
%             f2=g.*h;
%             
%             %PF
%             xiii_size=size(PopulationDecVars(:,xsplit(3,1):xsplit(3,2)),2);
%             plot(0:0.01:1,(1-((0:0.01:1).^((H+xiii_size*((1+H).^2))))),'b--');
%             hold on; scatter(f1,f2,150,'k.'); axis square; title(['Shang t=' num2str(t)]); hold off;
%             xlabel('f_1'); ylabel('gh')         
%             print(gcf,['PFShang_t=' num2str(t) '.png'],'-dpng','-r1200')
% 
% 
%             %% HELBIG2013
%             Npop=15;
%             xpop=[linspace(0,1,Npop)' zeros(Npop,1) zeros(Npop,1)];
%             PopulationDecVars=xpop;
%         
%             %Helbig 2013 version
%             f1=PopulationDecVars(:,xsplit(1,1):xsplit(1,2));
%             g=1+sum(PopulationDecVars(:,xsplit(2,1):xsplit(2,2)).^2,2);
%             H1=0.75+(0.75*sin(0.5*pi*t));
%             H2=1./(H1+sum((PopulationDecVars(:,xsplit(3,1):xsplit(3,2))-H1).^2,2));
%             h=1-((f1./g).^H2);
%             f2=g.*h;
%             
%             %PF
%             plot(0:0.01:1,(1-((0:0.01:1).^(1/(H1)))),'b--');
%             hold on; scatter(f1,f2,150,'k.'); axis square; title(['Helbig t=' num2str(t)]); hold off;
%             xlabel('f_1'); ylabel('gh')           
%             print(gcf,['PFHelbig_t=' num2str(t) '.png'],'-dpng','-r1200')
%    

            
            %%
            popObj=[f1 f2];
             

        end
        %%
        function popCon = CalcCon(thisProblem,PopulationDecVars)
            popCon=zeros(size(PopulationDecVars));
        end
        
        %% Sample reference points on Pareto front
        function P = ParetoFront(thisProblem,N)
            P = (0:(1/(N-1)):1)';
            %Shang + Farina
            H = 0.75+(0.7*sin(0.5*pi*thisProblem.t_val));
            P = [P (1-((0:(1/(N-1)):1).^(1/(H+thisProblem.DecVarsSplit(3)*((H).^2)))))'];
            
%             %Helbig
%             H = 0.75+(0.75*sin(0.5*pi*thisProblem.t_val));
%             P = [P (1-((0:(1/(N-1)):1).^(1/H)))'];
            
            
            %pd=[(0:1/(N-1):1)' 0.5*ones(N,thisProblem.DecVars-1)]; %Optimal decision vairables population

        end
    end
    
end
