function [y,trace]=gwobp(inputnum,hiddennum,outputnum,inputn_train,label_train,Pn_test,Tn_test)
d=inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum;%优化bp各层权重与阈值
N=20;                  %群体个数
D=d;                   %维数
T=1000;                  %最大迭代次数
w=0.8;
Xmin=-1;  % lower
Xmax=1; % upper

%
Alpha_pos=zeros(1,D);
Alpha_score=inf;
Beta_pos=zeros(1,D);
Beta_score=inf; %
Delta_pos=zeros(1,D);
Delta_score=inf; 
Positions=initialization(N,D,Xmax,Xmin);%初始化
trace=zeros(1,T);

l=0;

while l<T
    for i=1:size(Positions,1)
        
        Flag4Xmax=Positions(i,:)>Xmax;
        Flag4Xmin=Positions(i,:)<Xmin;
        Positions(i,:)=(Positions(i,:).*(~(Flag4Xmax+Flag4Xmin)))+Xmax.*Flag4Xmax+Xmin.*Flag4Xmin;
        
        fitness=fun1(Positions(i,:),inputnum,hiddennum,outputnum,Pn_test,Tn_test); 
        
        if fitness<Alpha_score
            Alpha_score=fitness; 
            Alpha_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness<Beta_score
            Beta_score=fitness; 
            Beta_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score
            Delta_score=fitness; 
            Delta_pos=Positions(i,:);
        end
    end
    
    
    a=2-l*((2)/T); 
    
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)
            
            r1=rand();
            r2=rand(); 
            
            A1=2*a*r1-a; 
            %C1=2*r2; 
            C1=0.5;
            
            D_alpha=abs(C1*Alpha_pos(j)-w*Positions(i,j)); 
            X1=Alpha_pos(j)-A1*D_alpha; 
            
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; 
            %C2=2*r2; 
            C2=0.5;
            
            D_beta=abs(C2*Beta_pos(j)-w*Positions(i,j)); 
            X2=Beta_pos(j)-A2*D_beta; 
            
            r1=rand();
            r2=rand();
            r3=rand();
            A3=2*a*r1-a;
            %C3=2*r2; 
            C3=0.5;
            D_delta=abs(C3*Delta_pos(j)-w*Positions(i,j));
            X3=Delta_pos(j)-A3*D_delta; 
             
            Positions(i,j)=(X1+X2+X3)/3;
         end  
    end
      l=l+1; 
        PositionsA(l,1)= Alpha_score;
        PositionsA(l,2)=fun1(Positions(i,:),inputnum,hiddennum,outputnum,inputn_train,label_train);
end
        trace=PositionsA;
        y=Positions(i,:);
end
