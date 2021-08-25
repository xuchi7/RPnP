function y = cal_pose_err(T1, T2)

R1= T1(1:3,1:3);
R2= T2(1:3,1:3);

X1= R1(:,1); X2= R2(:,1);
Y1= R1(:,2); Y2= R2(:,2);
Z1= R1(:,3); Z2= R2(:,3);

exyz= [X1'*X2 Y1'*Y2 Z1'*Z2];
exyz(exyz>1)= 1;
exyz(exyz<-1)= -1;

y(1)= max(abs(acos(exyz)))*180/pi;

y(2)= norm(T1(1:3,4)-T2(1:3,4))/norm(T2(1:3,4))*100;

y= abs(y);

return
