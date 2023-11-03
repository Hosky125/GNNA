% This function initialize the first population of search agents
function Positions=initialization(N,D,Xmax,Xmin)

Boundary_no= size(Xmax,2); % numnber of boundaries

% If the boundaries of all variables are equal and user enter a signle
% number for both ub and lb
if Boundary_no==1
    Positions=rand(N,D).*(Xmax-Xmin)+Xmin;
end

% If each variable has a different lb and ub
if Boundary_no>1
    for i=1:D
        ub_i=Xmax(i);
        lb_i=Xmin(i);
        Positions(:,i)=rand(N,1).*(Xmax_i-Xmin_i)+Xmin_i;
    end
end