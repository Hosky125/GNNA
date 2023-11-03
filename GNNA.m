%%清空环境变量
clc
clear
close all
format compact

%%导入数据
%%导入.csv文件用csvread(文件名，数据开始读取行，数据开始读取列)
DataSpecies=csvread('Pinellia930_DataSpecies.csv',1,3);
input=DataSpecies(:,2:7);%取遍所有的行，第2至7列，即所有的环境变量（自变量）
output=DataSpecies(:,1);%取遍所有的行，第1列，即响应变量（因变量）

data_ANN=[];
data_GNNA=[];
tic
for i=1:12
%%随机生成训练集、测试集
%rand('seed',0)
k=randperm(size(input,1));%产生1：size(input,1)的随机数，size(input,1)相当于行长度
m=round(0.8*size(input,1));%按照训练集：测试集=80/20
%%训练集
P_train=input(k(1:m),:);
T_train=output(k(1:m));
%%测试集
P_test=input(k(m+1:end),:);
T_test=output(k(m+1:end));

%%节点个数
inputnum=size(P_train',1);
hiddennum=5;
outputnum=size(T_train',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%BP神经网络(没有优化的)
net=newff(P_train',T_train',hiddennum);
net.trainParam.epochs=2000;%迭代最大次数
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%%BP网络训练
[net,per2]=train(net,P_train',T_train');
predict_ANN=sim(net,P_test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% data=[predict_ANN',T_test];
% After=data(:,1);%预测结果
% Before=data(:,2);%T_test
% result_table=table(After,Before);
% writetable(result_table,'Ageratum3137_ANN.csv')

data_ANN(:,i)=predict_ANN';
data_ANN(:,i+30)=T_test;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%灰狼群优化网络
[bestchrom,trace]=gwobp(inputnum,hiddennum,outputnum,P_train,T_train,P_test,T_test);%灰狼群算法
x=bestchrom;

%%用GWO优化的BP网络进行值预测
w1=x(1:inputnum*hiddennum);
B1=x(inputnum*hiddennum+1:inputnum*hiddennum+hiddennum);
w2=x(inputnum*hiddennum+hiddennum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum);
B2=x(inputnum*hiddennum+hiddennum+hiddennum*outputnum+1:inputnum*hiddennum+hiddennum+hiddennum*outputnum+outputnum);

net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(B1,hiddennum,1);
net.b{2}=B2';

%%网络进化参数
net.trainParam.epochs=2000;
net.trainParam.lr=0.1;
net.trainParam.goal=0.00000001;
net.trainParam.max_fail = 200;

%%GNNA网络训练
[net,per2]=train(net,P_train',T_train');
 
%%GNNA预测
predict_GNNA=sim(net,P_test');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%导出预测数据,算AUC,用R算
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
%%导出预测数据,算AUC,用R算
ANN_After=data_ANN(:,1:12);%预测结果
ANN_Before=data_ANN(:,31:42);%T_test
ANNresult_table=table(ANN_After,ANN_Before);
writetable(ANNresult_table,'Pinellia930_ANN.csv')

GNNA_After=data_GNNA(:,1:12);%预测结果
GNNA_Before=data_GNNA(:,31:42);%T_test
GNNAresult_table=table(GNNA_After,GNNA_Before);
writetable(GNNAresult_table,'Pinellia930_GNNA.csv')