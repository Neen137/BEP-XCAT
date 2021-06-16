
% script for generating parameter files for XCAT modelling with 
% variable anatomical features
% to be read by Execute_xcat.m
clc
clear
fclose('all');

%meta parameters for generating 4d xcat phantoms

abnormal = 0; %0 == healthy/normal, 1 == unhealthy/abnormal
time_per_frame = 0.49;
out_frames = 2;
n = 200; %number of male patients
%% Hidden parameters for experimental generation





%height_dist_male = [178.2 6.52 168.0 189.0]; %original
height_dist_male = [178.2 6.52 168.0 205.0];%adjusted
heights_male = TruncatedNormal(n, height_dist_male(1), height_dist_male(2), height_dist_male(3), height_dist_male(4));



gender = zeros(1,n); %if using female models, change to ones

%% Torso Scaling

standard_height = 175.23262; %from unchanged .log file
phantom_height_scale = heights_male/standard_height;

%for now phantom scales in all directions equally (find relation to torso
%dimensions with respect to height)
%correlated truncated normal if distribution is found
phantom_long_axis_scale = phantom_height_scale .* TruncatedNormal(n, 1, 0.005, 0.95, 1.05); %random max 5% variation
phantom_short_axis_scale = phantom_height_scale .* TruncatedNormal(n, 1, 0.005, 0.95, 1.05); %random max 5% variation


%% Heart scaling
%radial scaling of the heart CC of 0.8 with long axis scaling
%lv_rad_dist_male = [26.7 4.7 19.0 40.0];%original(mm) (systole) mean, std, min, max
lv_rad_dist_male = [26.7 4.7 19.0 36.1];%95% CI upper bound
lv_rad_male = correlated_truncated_normal(phantom_long_axis_scale, n, lv_rad_dist_male(1), lv_rad_dist_male(2), lv_rad_dist_male(3), lv_rad_dist_male(4), 0.8);
%longitudinal scaling of the heart CC of 0.8 with height scaling
%lv_l_dist_male = [83.1 9.3 66.0 116.0]; %original (mm) (systole) mean, std, min, max
lv_l_dist_male = [83.1 9.3 66.0 101.7]; %95% CI upper bound
lv_l_male = correlated_truncated_normal(phantom_height_scale, n, lv_l_dist_male(1), lv_l_dist_male(2), lv_l_dist_male(3), lv_l_dist_male(4), 0.8);
%standard:
%-------------LV Size (Diastole)----------
%  Length	     96.5130 mm's
%  Radius         31.8727 mm's
%-----------------------------------------
%-------------LV Size (Systole)----------
%  Length         85.4235 mm's
%  Radius         28.6712 mm's
%-----------------------------------------
lv_rad_standard = 28.6712;
lv_l_standard = 85.4235;
hrt_vert_scaling = lv_l_male ./ lv_l_standard;
hrt_rad_scaling = lv_rad_male ./ lv_rad_standard;

%scaling based on relation to standard phantom
%compensated for phantom scaling
%hrt_scale_x = hrt_rad_scaling   ./ phantom_long_axis_scale;
%hrt_scale_y = hrt_rad_scaling  ./ phantom_short_axis_scale;
%hrt_scale_z = hrt_vert_scaling   ./ phantom_height_scale;

%original solution gave extreme outliers, e.g. hrt_scale_x = 0.5
hrt_scale_x = TruncatedNormal(n, 0.95, 0.05, 0.8, 1.08);
hrt_scale_y = correlated_truncated_normal(hrt_scale_x, n , 0.95, 0.05, 0.8, 1.08, 0.85);
hrt_scale_z = correlated_truncated_normal(hrt_scale_x, n , 0.95, 0.05, 0.8, 1.08, 0.85);


%% Heart rotation and translation

male_hrtangle_1 = TruncatedNormal(n, 20, 9, 0, 41); 
%male_hrtangle_2 = TruncatedNormal(n, 36, 12, 15, 73);%adjust values to
%combat extreme heart rotation this source is shaky at best
%if the heart is bigger it lies further back
%((and goes right more)) -- not sure
%heart size
male_trans_lat = correlated_truncated_normal(phantom_long_axis_scale, n, 56, 11, 35, 80, 0.7);
male_trans_ap = correlated_truncated_normal(phantom_short_axis_scale, n, -64, 26, -116, 12, -0.7);
X_tr = male_trans_lat/10; %from mm to cm
Y_tr = male_trans_ap/10; %from mm to cm
Z_tr = TruncatedNormal(n, 0, 0.5, -1, 1); %arbitrary 1cm vertical variation

 
%d_XZ_rotation = male_hrtangle_2 - 27.128632;
d_XZ_rotation = TruncatedNormal(n, 0, 5, -20, 20);
d_YX_rotation = male_hrtangle_1 - 12.055756;
d_ZY_rotation = TruncatedNormal(n, 0, 5, -20, 20); %no patient data available; arbitrary 20 degree variation
%% Volume variation

%calculating EDV based on global and local scaling, validated within 1 ml
%error
EDV = hrt_scale_x .* hrt_scale_y .* hrt_scale_z .* phantom_height_scale .* phantom_long_axis_scale .* phantom_short_axis_scale * 132.1860; 

%define (healthy) EF and calculate ESV
if abnormal == 0
    
    EF = TruncatedNormal(n, 0.6123, 0.0506, 0.50, 0.70); 
else
    EF = TruncatedNormal(n, 0.375, 0.05, 0.30, 0.45);
end

ESV = -1*(EF .* EDV) + EDV;


%% Defining parameter struct

%anatomical parameters
anatpar.phantom_height_scale = phantom_height_scale;
anatpar.phantom_long_axis_scale = phantom_long_axis_scale;
anatpar.phantom_short_axis_scale = phantom_short_axis_scale;
anatpar.hrt_scale_x = hrt_scale_x;
anatpar.hrt_scale_y = hrt_scale_y;
anatpar.hrt_scale_z = hrt_scale_z;
anatpar.X_tr = X_tr;
anatpar.Y_tr = Y_tr;
anatpar.Z_tr = Z_tr;
anatpar.d_XZ_rotation = d_XZ_rotation;
anatpar.d_YX_rotation = d_YX_rotation;
anatpar.gender = gender;
anatpar.d_ZY_rotation = d_ZY_rotation;
anatpar.hrt_v2 = ESV;

%variables that can be changed but not needed for this approach
anatpar.resp_start_ph_index = zeros(1, n);
anatpar.read_user_objects = zeros(1, n);
anatpar.hrt_period = ones(1, n);

outframesl = zeros(1, n);
outframesl(:) = out_frames;
anatpar.out_frames = outframesl;

time_per_framel = zeros(1, n);
time_per_framel(:) = time_per_frame;
anatpar.time_per_frame = time_per_framel;

%% creating parameter files
fnames = string(fieldnames(anatpar));
for patientid = 1:(n)    
   str = '';
   format = '';
   for k = 1:numel(fnames)
       field = anatpar.(fnames(k));
       str = str + fnames(k) + ' = ' + field(patientid)+'\n'; %'fieldname = variable\n'
       format = string(format) + '%s\n'; %define format for file writing

       
   end
   %string to write to file
   str = compose(str);
   writestr = splitlines(str);
   writestr(end) = [];
   
   
   %define file name, formatting and writing file
   if abnormal == 0
       fname = 'Parameters\parameters_h_patient_' + string(patientid) + '.par'; %healthy
   else
       fname = 'Parameters\parameters_d_patient_' + string(patientid) + '.par'; %diseased
   end
   fileid = fopen(fname, 'w');
   fprintf(fileid, format, writestr);
   fclose(fileid);
   
   
  
end
fclose('all');
disp("Done creating " + string(n) + ' parameter files')

