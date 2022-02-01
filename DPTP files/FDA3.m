classdef FDA3 < DYNAMIC_PROBLEM
    
    
    properties
        %t_val = 1; 
        PF=[];
        DecVarsSplit;
    end
%     properties (Dependent)
%         %Calculated each time the value is requested
%     end
    methods
        function thisProblem = FDA3(varargin)
        %% Overloaded Constructor (must be public)
            thisProblem=thisProblem@DYNAMIC_PROBLEM(varargin{:});
            thisProblem.lowerDecBound=[0 -1];
            thisProblem.upperDecBound=[1 1];
            
            if sum(strcmp(varargin,'DecVarsSplit'))>0 
                thisProblem.DecVarsSplit=varargin{find(strcmp(varargin,'DecVarsSplit')==1)+1};
            else %Default t_range for FDA1:
                thisProblem.DecVarsSplit=[1 thisProblem.DecVars-1]; %VERIFY/JUSTIFY THESE NUMBERS
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
            F=10^(2*sin(0.5*pi*t));
            f1=sum(PopulationDecVars(:,xsplit(1,1):xsplit(1,2)).^(F),2);
            G=abs(sin(0.5*pi*t));
            g=1+G+sum((PopulationDecVars(:,xsplit(2,1):xsplit(2,2))-G).^2,2);
            h=1-sqrt(f1./g);

            f2=g.*h;
            
            
%             PF=(1+G)*(1-sqrt(F1))

%%% Into the command window:             
%%% figure; for t=-1:0.1:1; xobj=thisProblem.CalcObj(PopulationDecVars,t); end

%%% Then uncomment:
%              c=get(gca,'Children'); 
%              try c=c.Children(1).Color; catch; c=c(1).Color; end
%              hold on; scatter(f1,f2,'x','MarkerEdgeColor',c);
%              text(f1(floor(length(f1)/2)),f2(floor(length(f1)/2)),['t=' num2str(t)])

            
            popObj=[f1 f2];

            
        end
        %%
        function popCon = CalcCon(thisProblem,PopulationDecVars)
            popCon=zeros(size(PopulationDecVars));
        end
        
        %% Sample reference points on Pareto front
        function P = ParetoFront(thisProblem,N)
            F=10^(2*sin(0.5*pi*thisProblem.t_val));
            G = abs(sin(0.5*pi*thisProblem.t_val));
            
            xipop = repmat(linspace(0,1,N)',1,thisProblem.DecVarsSplit(1));
            xiipop = repmat(G,N,thisProblem.DecVarsSplit(2));
            
            P=sum(xipop.^(F),2);
            P=[P (1+G).*(1-sqrt(P))];
            %pd=[(0:1/(N-1):1)' 0.5*ones(N,thisProblem.DecVars-1)]; %Optimal decision vairables population
        
            %PF does not change, but PS does.
        end
    end
    
end
