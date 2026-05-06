% % NEED TO EDIT FOR THE SH RUNS
% 
% WK1:
filenamesWK1 = ["partoutput_20161228235959_init.nc", "partoutput_20161210095959.nc", ...
    "partoutput_20161121205959.nc", "partoutput_20161103075959.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK1/"; 
filenamesWK1 = file_prefix + filenamesWK1;

% WK2:
filenamesWK2 = ["partoutput_20170125235959_init.nc", "partoutput_20170107095959.nc", ...
    "partoutput_20161219205959.nc", "partoutput_20161201075959.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK2/";
filenamesWK2 = file_prefix + filenamesWK2;

% WK3:
filenamesWK3 = ["partoutput_20170222235959_init.nc", "partoutput_20170204095959.nc", ...
    "partoutput_20170116205959.nc", "partoutput_20161229075959.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK3/";
filenamesWK3 = file_prefix + filenamesWK3;

% WK4:
filenamesWK4 = ["partoutput_20170322210000_init.nc", "partoutput_20170304070000.nc", ...
    "partoutput_20170213180000.nc", "partoutput_20170126050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK4/";
filenamesWK4 = file_prefix + filenamesWK4;

% WK5:
filenamesWK5 = ["partoutput_20170419210000_init.nc", "partoutput_20170401070000.nc", ...
    "partoutput_20170313180000.nc", "partoutput_20170223050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK5/";
filenamesWK5 = file_prefix + filenamesWK5;

% WK6:
filenamesWK6 = ["partoutput_20170517210000_init.nc", "partoutput_20170429070000.nc", ...
    "partoutput_20170410180000.nc", "partoutput_20170323050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK6/";
filenamesWK6 = file_prefix + filenamesWK6;

% WK7:
filenamesWK7 = ["partoutput_20170614210000_init.nc", "partoutput_20170527070000.nc", ...
    "partoutput_20170508180000.nc", "partoutput_20170420050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK7/";
filenamesWK7 = file_prefix + filenamesWK7;

% WK8:
filenamesWK8 = ["partoutput_20170712210000_init.nc", "partoutput_20170624070000.nc", ...
    "partoutput_20170605180000.nc", "partoutput_20170518050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK8/";
filenamesWK8 = file_prefix + filenamesWK8;

% WK9:
filenamesWK9 = ["partoutput_20170809210000_init.nc", "partoutput_20170722070000.nc", ...
    "partoutput_20170703180000.nc", "partoutput_20170615050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK9/";
filenamesWK9 = file_prefix + filenamesWK9;

% WK10:
filenamesWK10 = ["partoutput_20170906210000_init.nc", "partoutput_20170819070000.nc",...
    "partoutput_20170731180000.nc", "partoutput_20170713050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK10/";
filenamesWK10 = file_prefix + filenamesWK10;

% WK11:
filenamesWK11 = ["partoutput_20171004210000_init.nc", "partoutput_20170916070000.nc", ...
    "partoutput_20170828180000.nc", "partoutput_20170810050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK11/";
filenamesWK11 = file_prefix + filenamesWK11;

% WK12:
filenamesWK12 = ["partoutput_20171101210000_init.nc", "partoutput_20171014070000.nc", ...
    "partoutput_20170925180000.nc", "partoutput_20170907050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK12/";
filenamesWK12 = file_prefix + filenamesWK12;

% WK13:
filenamesWK13 = ["partoutput_20171129210000_init.nc", "partoutput_20171111070000.nc", ...
    "partoutput_20171023180000.nc", "partoutput_20171005050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK13/";
filenamesWK13 = file_prefix + filenamesWK13;

% WK14:
filenamesWK14 = ["partoutput_20171227210000_init.nc", "partoutput_20171209070000.nc", ...
    "partoutput_20171120180000.nc", "partoutput_20171102050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK14/"; 
filenamesWK14 = file_prefix + filenamesWK14;

% WK15:
filenamesWK15 = ["partoutput_20180124210000_init.nc", "partoutput_20180106070000.nc", ...
    "partoutput_20171218180000.nc", "partoutput_20171130050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK15/"; 
filenamesWK15 = file_prefix + filenamesWK15;

% v2 --> edited so that the location around final days are actually 24
% apart rather than 25


% SaveFinalState_v3(filenamesWK1, 'SH_d_WK1_final_state', datetime(2016,12,28,23,59,0));
SaveFinalState_v3(filenamesWK2, 'SH_d_WK2_final_state_v2', datetime(2017,1,25,23,59,0));
SaveFinalState_v3(filenamesWK3, 'SH_d_WK3_final_state_v2', datetime(2017,2,22,23,59,0));
% SaveFinalState_v3(filenamesWK4, 'SH_d_WK4_final_state', datetime(2017,3,22,21,0,0));
% SaveFinalState_v3(filenamesWK5, 'SH_d_WK5_final_state', datetime(2017,4,19,21,0,0));
% SaveFinalState_v3(filenamesWK6, 'SH_d_WK6_final_state', datetime(2017,5,17,21,0,0));
% SaveFinalState_v3(filenamesWK7, 'SH_d_WK7_final_state', datetime(2017,6,14,21,0,0));
% SaveFinalState_v3(filenamesWK8, 'SH_d_WK8_final_state', datetime(2017,7,12,21,0,0));
SaveFinalState_v3(filenamesWK9, 'SH_d_WK9_final_state_v2', datetime(2017,8,9,21,0,0));
% SaveFinalState_v3(filenamesWK10, 'SH_d_WK10_final_state', datetime(2017,9,6,21,0,0));
% SaveFinalState_v3(filenamesWK11, 'SH_d_WK11_final_state', datetime(2017,10,04,21,0,0));
% SaveFinalState_v3(filenamesWK12, 'SH_d_WK12_final_state', datetime(2017,11,01,21,0,0));
% SaveFinalState_v3(filenamesWK13, 'SH_d_WK13_final_state', datetime(2017,11,29,21,0,0));
% SaveFinalState_v3(filenamesWK14, 'SH_d_WK14_final_state_v2', datetime(2017,12,27,21,0,0));
% SaveFinalState_v3(filenamesWK15, 'SH_d_WK15_final_state_v2', datetime(2018,1,24,21,0,0));
