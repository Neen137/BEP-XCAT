
fclose('all');

%-------------LV Volumes at Different Phases----------
%  V1 (end-diastole)
%  V2 (end-systole)
%  V3 (beg. quiet phase)
%  V4 (end quiet phase)
%  V5 (red. filling, diastole) 
%  V6 == EF
%  V7 == discrete ED volume form .bin file
%  V8 == Volume calculated by parameter file

patientslice = [6 107 87 31 32 76 101 102 103 104];
parpath = 'GeneratedPatients\00patient';
%% Read all volumes from .log file
for patientid = patientslice

    filename = parpath + string(patientid) + "_log";
    fileid = fopen(filename, 'r'); 
    rawstring = fscanf(fileid,'%c');
    fclose(fileid);
    splitstring = splitlines(rawstring);
    %splitstring(end) = [];
    index = find(contains(splitstring, 'LV Volumes at Different Phases'));
    volumestr = splitstring(index+1:index+5);
    volumes = zeros(1, 6);
    for i = 1:5
        line = split(volumestr(i));
        volumes(i) = string(line(end-1));
    end
    volumes(6) = (volumes(1)-volumes(2))/volumes(1);
    disp(volumes(6))
    patients.('patient'+string(patientid)) = volumes;    
    
    
end

%% Read EDV from .bin file
volumepervoxel = 1e-3;

for patientid = patientslice
   filename = parpath + string(patientid) + "_act_1.bin";
   fileidimg = fopen(filename);
   img = fread(fileidimg, 'float32');
   nvoxels_lv = sum(img(:) == 2);
   volume_lv = nvoxels_lv * volumepervoxel;
   patients.('patient'+string(patientid)) = [patients.('patient'+string(patientid)), volume_lv];
   fclose(fileidimg);
   
end
img = 1; %for memory 
%% Read volume from .par file

for patientid = patientslice
   filenamepar = 'Parameters\parameters_h_patient_' + string(patientid) + ".par";
   fileidpar = fopen(filenamepar);
   par = fscanf(fileidpar, '%c');
   fclose(fileidpar);
   splitstringpar = splitlines(par);
   scalestring = splitstringpar(1:6);
   parvolume = 132.1860;
   %using all scaling factors and standard volume
   for i = 1:6
       val = split(scalestring(i));
       val = val(end);
       parvolume = parvolume * str2double(val);
   end
   patients.('patient'+string(patientid)) = [patients.('patient'+string(patientid)), parvolume];
end

fclose('all');

%% plot EDV values for every patients
shapes = ['c', 'c', 'd'];
figure
hold on
i = 1;
c = linspace(1,10,length(patientslice));
diff = zeros(10,1);
for patientid = patientslice
    patientdata = patients.('patient'+string(patientid));
    patientdata = patientdata([1,7,8]);
    patientdata = patientdata/mean(patientdata);
    scatter(i, patientdata(1),100, 'black', '.')
    scatter(i, patientdata(2),100, 'red', '.')
    scatter(i, patientdata(3),100, 'cyan', '.')
    if i == 1
        legend('Log File Volume', 'Discrete Volume' ,'Parameter File Volume', 'autoupdate', 'off')
    end
    
    diff(i) =(mean([patientdata(1), patientdata(3)]) - patientdata(2));
    i = i + 1;
    
    
end

title('\fontsize{16}Normalized Volume Calculations')
xlabel('Patients')
ylabel('Normalized Volume')
hold off