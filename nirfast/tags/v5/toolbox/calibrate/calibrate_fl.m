function [data,mesh] = calibrate_fl(fmesh, data_meas, frequency, iteration)

% [data,mesh] = calibrate_fl(fmesh, data_meas, frequency)
%
% Calibrates fluor data and generates initial guess. Will skip
% the calibrate part if only fluorescence data is available.
%
% fmesh is the forward mesh (variable or filename)
% data_meas is the uncalibrated data (variable or filename)
%       contains data_meas.amplitudex and data_meas.amplitudefl
% frequency is the modulation frequency (MHz)
% iteration is the number of iterations for fitting
% data is the resulting calibrated data
% mesh is the resulting calibrated mesh with initial guess


% error checking
if frequency < 0
    errordlg('Frequency must be nonnegative','NIRFAST Error');
    error('Frequency must be nonnegative');
end

% If not a workspace variable, load mesh
if ischar(fmesh)== 1
  fmesh = load_mesh(fmesh);
end

mesh = fmesh;

% load data
if ischar(data_meas)
    data_meas = load_data(data_meas);
end

if ~isfield(data_meas,'amplitudefl')
    errordlg('Data not found or not properly formatted','NIRFAST Error');
    error('Data not found or not properly formatted');
end

% run forward model
data_fwd = femdata(fmesh, frequency);

% calculate calibrated data
if isfield(data_meas,'amplitudex') && isfield(data_fwd,'amplitudex')
    data.amplitudefl = data_meas.amplitudefl.*(data_fwd.amplitudex./data_meas.amplitudex);
else
    data.amplitudefl = data_meas.amplitudefl;
end



% ***********************************************************
% get initial guess


% Load data and set constant values

for m = 1 : size(fmesh.source.coord)
  for j = 1 : length(fmesh.link(m,:))
      datanum = datanum + 1;
      if isnan(data_meas.amplitudefl(datanum))
          fmesh.link(m,j) = 0;
      end
      if fmesh.link(m,j) == 0
          data_meas.amplitudefl(datanum) = NaN;
      end
  end
end

ind = find(isnan(data_meas.amplitudefl)==1);
ind = setdiff(1:size(data_meas.amplitudefl,1),ind);
lnI = log(data_meas.amplitudefl(ind));


err = [];
muafa = 10^-10;
muafb = 0.01;
deltamuaf = 10^-10;

disp('Initializing Bisection method points...')
% calculate point "a" for bisection method
mesh.muaf(:) = muafa;
[fem_data_a1]=femdata(mesh,frequency);    
fem_lnI_a1 = log(fem_data_a1.paafl(ind,1));
Err_a1 = sum((fem_lnI_a1-lnI).^2);

mesh.muaf(:) = muafa + deltamuaf;
[fem_data_a2]=femdata(mesh,frequency);
fem_lnI_a2 = log(fem_data_a2.paafl(ind,1));
Err_a2 = sum((fem_lnI_a2-lnI).^2);

dEa_dmuaf = (Err_a2 - Err_a1)/(deltamuaf);

% calculate point "b" for bisection method
mesh.muaf(:) = muafb;
[fem_data_b1]=femdata(mesh,frequency);    
fem_lnI_b1 = log(fem_data_b1.paafl(ind,1));
Err_b1 = sum((fem_lnI_b1-lnI).^2);

mesh.muaf(:) = muafb + deltamuaf;
[fem_data_b2]=femdata(mesh,frequency);
fem_lnI_b2 = log(fem_data_b2.paafl(ind,1));
Err_b2 = sum((fem_lnI_b2-lnI).^2);

dEb_dmuaf = (Err_b2 - Err_b1)/(deltamuaf);
        
% bisection method iteration
for i = 1:iteration

    muafc = muafa+(muafb - muafa)/2;
    
    mesh.muaf(:) = muafc;
    [fem_data_c1]=femdata(mesh,frequency);    
    fem_lnI_c1 = log(fem_data_c1.paafl(ind,1));
    Err_c1 = sum((fem_lnI_c1-lnI).^2);
    
    mesh.muaf(:) = muafc + deltamuaf;
    [fem_data_c2]=femdata(mesh,frequency);
    fem_lnI_c2 = log(fem_data_c2.paafl(ind,1));
    Err_c2 = sum((fem_lnI_c2-lnI).^2);
    mesh.muaf(:) = muafc;
    
    dEc_dmuaf = (Err_c2 - Err_c1)/(deltamuaf);
    
    test_a = dEc_dmuaf * dEa_dmuaf;
    test_b = dEc_dmuaf * dEb_dmuaf;
    
    disp(['point a = ',num2str(dEa_dmuaf),'  point b = ',num2str(dEb_dmuaf),'  point c = ',num2str(dEc_dmuaf)])
    if test_a < 0 & test_b > 0
        muafb = muafc;
        dEb_dmuaf = dEc_dmuaf;
    elseif test_b < 0 & test_a > 0
        muafa = muafc;
        dEa_dmuaf = dEc_dmuaf;
    end
    
    err = [err Err_c1];
    
    if i>1 & abs(err(end)-err(end-1))<10^-5
        disp(['Stopping Criteria Reached at iteration ' num2str(i)]);
        disp('Global values calculated from Numerical fit');
        disp(['muaf = ' num2str(muafc) ' mm-1 with error of ' num2str(err(end))]);
        disp('-------------------------------------------------');
        return
    end
    disp(['Iteration = ' num2str(i)]);
    disp('Global values calculated from Numerical fit');
    disp(['muaf = ' num2str(muafc) ' mm-1 with error of ' num2str(err(end))]);
    disp('-------------------------------------------------');
end