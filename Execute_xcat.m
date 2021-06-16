
patientslice = [9]; %patient_ids to be generated
abnormal = 1;% 0 == healthy/normal ; 1 == diseased/abnormal
if abnormal == 0 
    parpath = '..\Parameters\parameters_h_patient_';
else
    parpath = '..\Parameters\parameters_d_patient_';
    
end
    
cd XCATprogram\

for patientid = patientslice
    
    fileid = fopen(parpath + string(patientid) + '.par', 'r');
    rawstring = fscanf(fileid,'%c');
    fclose(fileid);
    splitstring = splitlines(rawstring);
    splitstring(end) = [];
    argchain = '';
    for i = 1:numel(splitstring)
        arg = split(splitstring(i));
        arg(2) = [];
        arg = '--' + string(join(arg)) + ' ';
        argchain = argchain + arg;
        
    

    end
    %change first argument to name of executable and second one to standard
    %parameter file
    command = '.\dxcat_sina.exe .\11Nov2020_384.par ' + argchain + ' ..\GeneratedPatients\0' + string(abnormal) + 'patient' + string(patientid);
    disp("Working...");

    system(command)
end
cd ..
disp("Done");