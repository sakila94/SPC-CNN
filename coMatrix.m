function y = coMatrix(im)


%% reading image
im = im2double(im);
% subplot(131);
% imshow(im);

%% bayer filtering
cfr = zeros(size(im));
cfr(2:2:end,1:2:end,1) = 1;
cfr(1:2:end,1:2:end,2) = 1;
cfr(2:2:end,2:2:end,2) = 1;
cfr(1:2:end,2:2:end,3) = 1;

sampled = double(im).*cfr;
% figure();
% imshow(sampled);

%% bilinear interpolation
BLIkernel(:,:,1) = [1 2 1; 2 4 2; 1 2 1]/4;
BLIkernel(:,:,2) = [0 1 0; 1 4 1; 0 1 0]/4;
BLIkernel(:,:,3) = [1 2 1; 2 4 2; 1 2 1]/4;

ref1(:,:,1) = conv2(sampled(:,:,1),BLIkernel(:,:,1),'same');
ref1(1,:,1) = ref1(1,:,1)*2;
ref1(:,end,1) = ref1(:,end,1)*2;

ref1(:,:,2) = conv2(sampled(:,:,2),BLIkernel(:,:,2),'same');
ref1(1,2:2:end,2) = ref1(1,2:2:end,2)*4/3;
ref1(end,1:2:end,2) = ref1(end,1:2:end,2)*4/3;
ref1(2:2:end,1,2) = ref1(2:2:end,1,2)*4/3;
ref1(1:2:end,end,2) = ref1(1:2:end,end,2)*4/3;

ref1(:,:,3) = conv2(sampled(:,:,3),BLIkernel(:,:,3),'same');
ref1(end,:,3) = ref1(end,:,3)*2;
ref1(:,1,3) = ref1(:,1,3)*2;
% subplot(132);
% imshow(ref1);

%% nearest neighbour

ref2 = sampled;
%red
ref2(1:2:end,:,1) = sampled(2:2:end,:,1);
ref2(:,2:2:end,1) = ref2(:,1:2:end,1);

%green
ref2(2:2:end,1:2:end,2) = ref2(1:2:end,1:2:end,2);
ref2(1:2:end,2:2:end,2) = ref2(2:2:end,2:2:end,2);

%blue
ref2(2:2:end,:,3) = ref2(1:2:end,:,3);
ref2(:,1:2:end,3) = ref2(:,2:2:end,3);

% subplot(133);
% imshow(ref2);


%% demosacing error
E1 = int8((im - ref1)*255);
E2 = int8((im - ref2)*255);

q = 2;
T = 3;
T = int8(T);

E1 = round(E1/q);
E2 = round(E2/q);

trunc = @(x) (int8(x<-T)*-T + int8(x>=-T & x<=T).*x + int8(x>T)*T);
E1 = trunc(E1) + T + 1;
E2 = trunc(E2) + T + 1;

%% E1
% G1 = E1(1:2:end,1:2:end,:);
% G2 = E1(2:2:end,2:2:end,:);
% B = E1(1:2:end,2:2:end,:);
% R = E1(2:2:end,1:2:end,:);

%% Intra-channel co-occurrence RED 
layer = [1 1 1];
id = [1 2 4];

% E1
co1 = jointCooccurrence(E1,id,layer);

% E2 
co3 = jointCooccurrence(E2,id,layer);


%% Inter-channel co-occurrence RED GREEN
layer = [1 1 2];
id1 = [1 2 2];
id2 = [2 4 2];

w1 = jointCooccurrence(E1,id1,layer);
w2 = jointCooccurrence(E1,id2,layer);
co2 = w1 + w2;

w1 = jointCooccurrence(E2,id1,layer);
w2 = jointCooccurrence(E2,id2,layer);
co4 = w1 + w2;


y(:,:,1:7)  = co1;
y(:,:,8:14) = co2;
y(:,:,15:21)  = co3;
y(:,:,22:28) = co4;


end
