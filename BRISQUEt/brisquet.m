function prediction = brisquet(im)

addpath('./misc_functions/')
path = './dist_levels/';


%% get all features (run to extract features) commented for now, because features already extracted
% labels = [];
% feats = [];
% for dist_level = 1:31
%     for num = 1:100
%         img_name = sprintf([path,'/%d/','meme_%d.jpg'],dist_level, num);
%         disp(img_name);
%         img = double(rgb2gray(imread(img_name)));
%         feat = brisque_feature(img);
%         feats = [feats; feat];
%         labels = [labels;dist_level];
%     end
% end
% image_id = repmat(1:100, [1, 31]);
% image_id = image_id';

%% load saved features and labels
load('feats_label_pair.mat')

train_feats = feats;
train_labels = labels;

mu_class = mean(train_feats);
mutrain = repmat(mu_class,[size(train_feats,1) 1]); 

std_class = std(train_feats);
stdtrain = repmat(std_class,[size(train_feats,1) 1]);

%% standard scaling of features

dataTrain = (train_feats - mutrain)./stdtrain;
valueTrain = train_labels;


%% test scaling
img = double(rgb2gray(im));
feat = brisque_feature(img);
dataTest = (feat - mu_class)./std_class;

%% svm params
cv = 0;
C = 128;
g = 0.01;

bestC = C;
bestg = g;

%% uncommment below code to run cross validation provided cv = 1
% if cv
%     folds = 5;
%     [C,gamma] = meshgrid(4:8, -6:-2);
%     %
%     % %# grid search, and cross-validation
%     cv_acc = zeros(numel(C),1);
%     for jj=1:numel(C)
%         cv_acc(jj) = svmtrain(valueTrain, dataTrain, ...
%             sprintf('-s 4 -c %f -g %f -v %d -q',2^C(jj), 2^gamma(jj), folds));
%     end
%     
%     %# pair (C,gamma) with best accuracy
%     [~,idx] = min(cv_acc);
%     %# now you can train you model using best_C and best_gamma
%     bestC = 2^C(idx);
%     bestg = 2^gamma(idx);
% else
%     bestC = C;
%     bestg = g;
% end

%% train
cmd = ['-s 4 -c ' num2str(bestC) ' -g ' num2str(bestg) ' -q'];
model_reg = svmtrain(valueTrain, dataTrain, cmd);


%% test
[prediction, ~,~] = svmpredict(0,dataTest,model_reg);
end