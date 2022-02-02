classdef DYNAMIC_PROBLEM < PROBLEM
    % Novel class structure designed for DPTP 2021 (inspired by PlatEMO format). 
    % Borrows from the superclass PROBLEM. Together with an Algorithm Object can be used to
    % carry out experiments on DMOP parameter settings. See ALGORITHM for
    % more details.
    
    %Example Command Window Usage: (GUI usage is recommended - simply type " DPTP " into the command window and hit enter.
    %1. Define a Problem Object: P1=dMOP1('dMOP1','real',<NumberOfDecisionVariables>,<NumberOfObjectives>)
    %2. Additional settings for the problem such as dynamic parameters can
    %be set as input by including the label for the variable immediately
    %before it in the inputs e.g.: ...,'t_change_frequency',20,...
    
    properties
        t_state = 0; %integer         
        t_loop_behaviour = 'mirror'; %string from {'mirror','reset','halt'}
        n_dynamic_dependencies = 1; %integer
        
        t_range  %Max number range for t 1x2 array
        t_step_size  %real value
        t_change_frequency %integer value
        t_change_time_units %string explaining time measure {'seconds','evaluations','generations'}
        t_current_time %dependent on the units above, defualt is 0
        t_change_direction
        t_val %Real valued - the transformed version of t_state to fit this specific problem 
        
        dynamic_onset_delay; %measured in generations usually
        Dynamic_Response_Flag = 0; 
    end
    properties (Access = private)
        t_last_change
        t_update_flag 
    end
    
    methods
        %% Overloaded Constructor (must be public)
        function thisProblem = DYNAMIC_PROBLEM(varargin)
            
            thisProblem=thisProblem@PROBLEM(varargin{:});
            
            defaults={thisProblem.DecVars,0.1,100,'generations',0};
            if sum(strcmp(varargin,'t_range'))>0 
                thisProblem.t_range=varargin{find(strcmp(varargin,'t_range')==1)+1};
            else 
                thisProblem.t_range=defaults{1}; 
            end
            if sum(strcmp(varargin,'t_step_size'))>0 
                thisProblem.t_step_size=varargin{find(strcmp(varargin,'t_step_size')==1)+1};
            else 
                thisProblem.t_step_size=defaults{2}; 
            end
            if sum(strcmp(varargin,'t_change_frequency'))>0 
                thisProblem.t_change_frequency=varargin{find(strcmp(varargin,'t_change_frequency')==1)+1};
            else 
                thisProblem.t_change_frequency=defaults{3}; 
            end
            if sum(strcmp(varargin,'t_change_time_units'))>0 
                thisProblem.t_change_time_units=varargin{find(strcmp(varargin,'t_change_time_units')==1)+1};
            else 
                thisProblem.t_change_time_units=defaults{4}; 
            end
            if sum(strcmp(varargin,'t_loop_behaviour'))>0 
                thisProblem.t_loop_behaviour=varargin{find(strcmp(varargin,'t_loop_behaviour')==1)+1};
            else 
                thisProblem.t_loop_behaviour='cycle'; 
            end
            if sum(strcmp(varargin,'dynamic_onset_delay'))>0 
                thisProblem.dynamic_onset_delay=varargin{find(strcmp(varargin,'dynamic_onset_delay')==1)+1};
            else 
                thisProblem.dynamic_onset_delay=50; 
            end
            
            if thisProblem.t_range(1)<thisProblem.t_range(2); thisProblem.t_change_direction=1; else; thisProblem.t_change_direction=-1; end
            thisProblem.t_current_time=0;
            thisProblem.t_last_change=0;
            thisProblem.t_val=GETt_val(thisProblem);
            
        end
        
        %% %Update Current time
        function [thisProblem,Population] = UpdateTime(thisProblem,AlgorithmObj,Population)
%             if strcmp(thisProblem.t_change_time_units,'seconds')==1
            if strcmp(thisProblem.t_change_time_units,'evaluations')==1
                thisProblem.t_current_time=AlgorithmObj.evalConsumed;
            elseif strcmp(thisProblem.t_change_time_units,'generations')==1    
                thisProblem.t_current_time=floor(AlgorithmObj.evalConsumed/AlgorithmObj.Npop);
            end
            
            if thisProblem.t_current_time == thisProblem.t_last_change+thisProblem.t_change_frequency
                thisProblem.t_last_change=thisProblem.t_current_time;
                thisProblem.t_update_flag=1;
                
                %Response Mechanism Flag goes here
                if AlgorithmObj.Dynamic_Response(1)>0
                    thisProblem.Dynamic_Response_Flag=1;
                end
                
                
                %--------------%
                %Stalled dynamic delay onset by 50 (default) generations
                if AlgorithmObj.evalConsumed<(thisProblem.dynamic_onset_delay*AlgorithmObj.Npop)
                    thisProblem.t_update_flag=0;
                    thisProblem.Dynamic_Response_Flag=0;
                end
                %--------------%
                
                %Update the tvalue - Add in difference between cycle and mirror t_loop_behaviour           
                if thisProblem.t_val+(thisProblem.t_change_direction*thisProblem.t_step_size)>thisProblem.t_range(2)
                    thisProblem.t_change_direction=thisProblem.t_change_direction*(-1);
                elseif thisProblem.t_val+(thisProblem.t_change_direction*thisProblem.t_step_size)<thisProblem.t_range(1)
                    thisProblem.t_change_direction=thisProblem.t_change_direction*(-1);
                end %Overflow is not handled yet: e.g. stepsize=0.3; t_val=1.8; t_range(2)=2; -> next_t_val=1.5
                thisProblem.t_val=GETt_val(thisProblem);
                

                if thisProblem.t_update_flag==1
                    Population.objs=thisProblem.CalcObj(Population.decs);
                    AlgorithmObj.evalConsumed=AlgorithmObj.evalConsumed+size(Population.decs,1);
                    %Since the Algorithm objecti is not returned from this function, the total consumed does not increase - these are free evaluations?
                    % -> Not important for the current experiments
                    Population.cons=thisProblem.CalcCon(Population.decs); 
                    thisProblem.PF=thisProblem.ParetoFront(100);
                    thisProblem.t_update_flag=0;
                end
            end
        end
        
        %% Getter function for t_val
        function t_val = GETt_val(thisProblem)
            if thisProblem.t_current_time == 0 %Initial t_val value
                t_val = thisProblem.t_range(1);
            elseif thisProblem.t_update_flag == 1
                t_val=round(thisProblem.t_val+(thisProblem.t_change_direction*thisProblem.t_step_size),3);
            else
                t_val = thisProblem.t_val;
            end
            %Change depending on loop behaviours
            
        end
        
    end
    
end