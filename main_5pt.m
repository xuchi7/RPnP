clear; clc;
addpath epnp;
addpath lhm;
addpath func;

% experimental parameters
nls= 0.5:0.5:5;
npt= 5;
num= 1000;

% compared methods
A= zeros(size(nls));
B= zeros(num,1);
name= {'DLT', 'EPnP', 'EPnP+GN', 'LHM', 'RPnP'};
f= {@DLT, @EPnP, @EPnP_GN, @LHM, @RPnP};
marker= {'.', 'x', 'o', '+', '^'};
color= {'r','g','b','c','m'};
markerfacecolor=  {'r','g','n','c','m'};

method_list= struct('name', name, 'f', f, 'mean_r', A, 'mean_t', A,...
    'med_r', A, 'med_t', A, 'std_r', A, 'std_t', A, 'r', B, 't', B,...
    'marker', marker, 'color', color, 'markerfacecolor', markerfacecolor);

% experiments
for i= 1:length(nls)
    
    nl= nls(i);
    fprintf('nl = %.1f: ',nl);
    
    for j= 1:num
        
        % camera's parameters
        width= 640;
        height= 480;
        f= 800;
        
        % generate 3d coordinates in camera space
        Xc= [xrand(1,npt,[-2 2]); xrand(1,npt,[-2 2]); xrand(1,npt,[4 8])];
        t= mean(Xc,2);
        R= rodrigues(randn(3,1));
        XXw= inv(R)*(Xc-repmat(t,1,npt));
        
        % projection
        xx= [Xc(1,:)./Xc(3,:); Xc(2,:)./Xc(3,:)]*f;
        xxn= xx+randn(2,npt)*nl;

        % pose estimation
        for k= 1:length(method_list)
            [R1,t1]= method_list(k).f(XXw,xxn/f);
            y= cal_pose_err([R1 t1],[R t]);
            method_list(k).r(j)= y(1);
            method_list(k).t(j)= y(2);
        end

        showpercent(j,num);
    end
    fprintf('\n');
    
    % save result
    for k= 1:length(method_list)
        method_list(k).mean_r(i)= mean(method_list(k).r);
        method_list(k).mean_t(i)= mean(method_list(k).t);
        method_list(k).med_r(i)= median(method_list(k).r);
        method_list(k).med_t(i)= median(method_list(k).t);
        method_list(k).std_r(i)= std(method_list(k).r);
        method_list(k).std_t(i)= std(method_list(k).t);
    end
end

close all;
yrange= [0 30];

i= 0; w= 350; h= 350;

figure('color','w','position',[w*i,100,w,h]);i=i+1;
xdrawgraph(nls,yrange,method_list,'mean_r','Mean Rotation Error',...
    'Gaussian Image Noise (pixels)','Rotation Error (degrees)');

figure('color','w','position',[w*i,100,w,h]);i=i+1;
xdrawgraph(nls,yrange,method_list,'med_r','Median Rotation Error',...
    'Gaussian Image Noise (pixels)','Rotation Error (degrees)');

figure('color','w','position',[w*i,100,w,h]);i=i+1;
xdrawgraph(nls,yrange,method_list,'mean_t','Mean Translation Error',...
    'Gaussian Image Noise (pixels)','Translation Error (%)');

figure('color','w','position',[w*i,100,w,h]);i=i+1;
xdrawgraph(nls,yrange,method_list,'med_t','Median Translation Error',...
    'Gaussian Image Noise (pixels)','Translation Error (%)');
