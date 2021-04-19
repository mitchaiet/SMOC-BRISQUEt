function feat = brisque_feature(imdist)

%------------------------------------------------
% Feature Computation
%-------------------------------------------------
imdist = double(imdist);
scalenum = 2;
window = fspecial('gaussian',7,7/6);
window = window/sum(sum(window));

feat = [];

for itr_scale = 1:scalenum

mu            = filter2(window, imdist, 'same');
mu_sq         = mu.*mu;
sigma         = sqrt(abs(filter2(window, imdist.*imdist, 'same') - mu_sq));
structdis     = (imdist-mu)./(sigma+1);


[alpha overallstd]       = estimateggdparam(structdis(:));
feat                     = [feat alpha overallstd^2]; 

% [h x] = hist(structdis(:),100);
% y = zeros(size(x));
% 
% y = exp(- (x.^2/(2*overallstd.^2)).^(alpha/2));
%                     beta = overallstd*(Gamma())
%                     y = exp(- (abs(x)/(2*.^2)).^(alpha/2));
%                     h = h./sum(h); y = y./sum(y);
%                     figure
%                     bar(x,h,'w');
%                     hold on;
%                     plot(x,y,'r','LineWidth',1.2);
%                     grid on
%                     legend('Empirical Historgram','Fit')



shifts                   = [ 0 1;1 0 ; 1 1; -1 1 ];

pairs= [];
for itr_shift =1 : length(shifts)
 
shifted_structdis        = circshift(structdis,shifts(itr_shift,:));
pair                     = structdis(:).*shifted_structdis(:);
[alpha leftstd rightstd] = estimateaggdparam(pair);
const                    =(sqrt(gamma(1/alpha))/sqrt(gamma(3/alpha)));
meanparam                =(rightstd-leftstd)*(gamma(2/alpha)/gamma(1/alpha))*const;
feat                     =[feat alpha meanparam leftstd^2 rightstd^2];
end

imdist                   = imresize(imdist,0.5);

end
