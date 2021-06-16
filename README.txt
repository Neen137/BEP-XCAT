All scripts used for BEP XCAT parameter variation

Generate_parfiles.m is a standalone script

Execute_xcat.m requires licensed 4D-XCAT software, does not function without a complete \XCATprogram directory


Intended order of operation:

- Generate_parfiles.m   (options: healthy or abnormal EF, number of parameter files)
- Execute_xcat.m	(options: healthy or abnormal .par files, patientslice = [patientid1, patientid2, ...](select .par files to simulate)


