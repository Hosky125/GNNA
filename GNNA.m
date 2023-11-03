%%��ջ�������
clc
clear
close all
format compact

%%��������
%%����.csv�ļ���csvread(�ļ��������ݿ�ʼ��ȡ�У����ݿ�ʼ��ȡ��)
DataSpecies=csvread('Pinellia930_DataSpecies.csv',1,3);
input=DataSpecies(:,2:7);%ȡ�����е��У���2��7�У������еĻ����������Ա�����
output=DataSpecies(:,1);%ȡ�����е��У���1�У�����Ӧ�������������

data_ANN=[];
data_GNNA=[];
tic
for i=1:12
%%�������ѵ���������Լ�
%rand('seed',0)
k=randperm(size(input,1));%����1��size(input,1)���������size(input,1)�൱���г���
m=round(0.8*size(input,1));%����ѵ���������Լ�=80/20
%%ѵ����
P_train=input(k(1:m),:);
T_train=output(k(1:m));
%%���Լ�
P_test=input(k(m+1:end),:);
T_test=output(k(m+1:end));

%%�ڵ����
inputnum=size(P_train',1);
hiddennum=5;
outputnum=size(T_train',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%BP������(û���Ż���)
net=newff(P_train',T_train',hiddennum);
net.trainParam.epochs=2000;%����������
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%%BP����ѵ��
[net,per2]=train(net,P_train',T_train');
predict_ANN=sim(net,P_test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data=[predict_ANN',T_test];
% After=data(:,1);%Ԥ����
% Before=data(:,2);%T_test
% result_table=table(After,Before);
% writetable(result_table,'Ageratum3137_ANN.csv')

data_ANN(:,i)=predict_ANN';
data_ANN(:,i+30)=T_test;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%����Ⱥ�Ż�����
[bestchrom,trace]=gwobp(inputnum,hiddennum,outputnum,P_train,T_train,P_test,T_test);%����Ⱥ�㷨
x=bestchrom;

%%��GWO�Ż���BP�������ֵԤ��
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';

%%�����������
net.trainParam.epochs=2000;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%%GNNA����ѵ��
[net,per2]=train(net,P_train',T_train');
 
%%GNNAԤ��
predict_GNNA=sim(net,P_test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%����Ԥ������,��AUC,��R��
% data=[predict_GNNA',T_test];
% After=data(:,1);
% Before=data(:,2);
% result_table=table(After,Before);
% writetable(result_table,'Ageratum3137_GNNA.csv')

data_GNNA(:,i)=predict_GNNA';
data_GNNA(:,i+30)=T_test;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
toc
%%����Ԥ������,��AUC,��R��
ANN_After=data_ANN(:,1:12);%Ԥ����
ANN_Before=data_ANN(:,31:42);%T_test
ANNresult_table=table(ANN_After,ANN_Before);
writetable(ANNresult_table,'Pinellia930_ANN.csv')

GNNA_After=data_GNNA(:,1:12);%Ԥ����
GNNA_Before=data_GNNA(:,31:42);%T_test
GNNAresult_table=table(GNNA_After,GNNA_Before);
writetable(GNNAresult_table,'Pinellia930_GNNA.csv')