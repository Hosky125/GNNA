
clc
clear
close all
format compact

DataSpecies=csvread('Pinellia930_DataSpecies.csv',1,3);
input=DataSpecies(:,2:7);
output=DataSpecies(:,1);

data_ANN=[];
data_GNNA=[];
tic
for i=1:12

k=randperm(size(input,1));
m=round(0.8*size(input,1));

P_train=input(k(1:m),:);
T_train=output(k(1:m));

P_test=input(k(m+1:end),:);
T_test=output(k(m+1:end));

inputnum=size(P_train',1);
hiddennum=5;
outputnum=size(T_train',1);

net=newff(P_train',T_train',hiddennum);
net.trainParam.epochs=2000;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

[net,per2]=train(net,P_train',T_train');
predict_ANN=sim(net,P_test');

data_ANN(:,i)=predict_ANN';
data_ANN(:,i+30)=T_test;

[bestchrom,trace]=gwobp(inputnum,hiddennum,outputnum,P_train,T_train,P_test,T_test);
x=bestchrom;

w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';

net.trainParam.epochs=2000;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

[net,per2]=train(net,P_train',T_train');
 
predict_GNNA=sim(net,P_test');

data_GNNA(:,i)=predict_GNNA';
data_GNNA(:,i+30)=T_test;
end
toc

ANN_After=data_ANN(:,1:12);
ANN_Before=data_ANN(:,31:42);%T_test
ANNresult_table=table(ANN_After,ANN_Before);
writetable(ANNresult_table,'Pinellia930_ANN.csv')

GNNA_After=data_GNNA(:,1:12);
GNNA_Before=data_GNNA(:,31:42);%T_test
GNNAresult_table=table(GNNA_After,GNNA_Before);
writetable(GNNAresult_table,'Pinellia930_GNNA.csv')
