function bf = create_basisfunction(amp)
% Description:
% Create the canonical HRF basis set and temporal/dispersion derivatives
% used by the cluster-mean fitting scripts.

%% get 3 basis functions with TR = 1
dt = 1;
fMRI_T   = spm_get_defaults('stats.fmri.t');
[bf, p]  = spm_hrf(dt,[],fMRI_T);

%bf = bf*amp;
%-Add time derivative
dp       = 1;
p(6)     = p(6) + dp;
D        = (bf(:,1) - spm_hrf(dt,p,fMRI_T))/dp;
bf       = [bf D(:)];
p(6)     = p(6) - dp;

%-Add dispersion derivative
dp   = 0.01;
p(3) = p(3) + dp;
D    = (bf(:,1) - spm_hrf(dt,p,fMRI_T))/dp;
bf   = [bf D(:)];

%% compute BOLD using 3 basis 
% input = [1, zeros(1,18)]; % stick function
% 
% bold = conv(input,bf(:,1)) + conv(input,bf(:,2)) + conv(input,bf(:,3))
end
