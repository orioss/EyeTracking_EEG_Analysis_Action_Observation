function [display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap()
% GetESCDisplayMap is a hard-coded function, specific to our study

%% Syntax
% [display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap()
%
%% Description
% GetESCDisplayMap is a hard-coded function, that contains specific details
% about our displays - what is the video names, which actor, times of
% translated intervals, which hand was used, and which condition
% (efficient/inefficient) 

% no input arguments.
%
% Output.
% display_details_in_num:
% Creating a display map which includes the names of the display and the
% details by which the EEG will be analyzed:
% display_details{1} = which hand
% display_details{1} = which condition
% display_details{1} = the presenter ID

% display_names: names of the video file as they appeared in the SMI BeGaze
% program.
%
% display_interval_times_in_ms: Interval times as they appear in the SMI
% BeGaze program - these are part of the action that are relevant for
% analyses. It is redundant if the videos ahs the exact same movement times
% (like in the our study)
%
%%
    display_names{1} = 'ESC_Right_Asia_Goal1';  
    display_details_in_num(1,1)=1;
    display_details_in_num(1,2)=1;
    display_details_in_num(1,3)=1;
    display_interval_times_in_ms(1,1)=2541;
    display_interval_times_in_ms(1,2)=4059;
    display_interval_times_in_ms(1,3)=5577;
    
    display_names{2} = 'ESC_Right_Asia_Goal2';
    display_details_in_num(2,1)=1;
    display_details_in_num(2,2)=2;
    display_details_in_num(2,3)=1;
    display_interval_times_in_ms(2,1)=2277;
    display_interval_times_in_ms(2,2)=4059;
    display_interval_times_in_ms(2,3)=5280;
    
    
    display_names{3} = 'ESC_Right_Asia_Initial1';
    display_details_in_num(3,1)=1;
    display_details_in_num(3,2)=3;
    display_details_in_num(3,3)=1;
    display_interval_times_in_ms(3,1)=2508;
    display_interval_times_in_ms(3,2)=4059;
    display_interval_times_in_ms(3,3)=5577;
    
    display_names{4} = 'ESC_Right_Asia_Initial2';
    display_details_in_num(4,1)=1;
    display_details_in_num(4,2)=4;
    display_details_in_num(4,3)=1;
    display_interval_times_in_ms(4,1)=2937;
    display_interval_times_in_ms(4,2)=4224;
    display_interval_times_in_ms(4,3)=5247;
    
    display_names{5} = 'ESC_Right_Danyang_Goal1';
    display_details_in_num(5,1)=1;
    display_details_in_num(5,2)=1;
    display_details_in_num(5,3)=2;
    display_interval_times_in_ms(5,1)=2343;
    display_interval_times_in_ms(5,2)=4092;
    display_interval_times_in_ms(5,3)=5115;
    
    display_names{6} = 'ESC_Right_Danyang_Goal2';
    display_details_in_num(6,1)=1;
    display_details_in_num(6,2)=2;
    display_details_in_num(6,3)=2;
    display_interval_times_in_ms(6,1)=2277;
    display_interval_times_in_ms(6,2)=4191;
    display_interval_times_in_ms(6,3)=5346;
    
    display_names{7} = 'ESC_Right_Danyang_Initial1';
    display_details_in_num(7,1)=1;
    display_details_in_num(7,2)=3;
    display_details_in_num(7,3)=2;
    display_interval_times_in_ms(7,1)=2673;
    display_interval_times_in_ms(7,2)=3927;
    display_interval_times_in_ms(7,3)=5115;
    
    display_names{8} = 'ESC_Right_Danyang_Initial2';
    display_details_in_num(8,1)=1;
    display_details_in_num(8,2)=4;
    display_details_in_num(8,3)=2;
    display_interval_times_in_ms(8,1)=2574;
    display_interval_times_in_ms(8,2)=4125;
    display_interval_times_in_ms(8,3)=5115;
    
    display_names{9} = 'ESC_Right_Niho_Goal1';
    display_details_in_num(9,1)=1;
    display_details_in_num(9,2)=1;
    display_details_in_num(9,3)=3;
    display_interval_times_in_ms(9,1)=2178;
    display_interval_times_in_ms(9,2)=4026;
    display_interval_times_in_ms(9,3)=5346;
    
    display_names{10} = 'ESC_Right_Niho_Goal2';
    display_details_in_num(10,1)=1;
    display_details_in_num(10,2)=2;
    display_details_in_num(10,3)=3;
    display_interval_times_in_ms(10,1)=2409;
    display_interval_times_in_ms(10,2)=4323;
    display_interval_times_in_ms(10,3)=7095;
    
    display_names{11} = 'ESC_Right_Niho_Initial1';
    display_details_in_num(11,1)=1;
    display_details_in_num(11,2)=3;
    display_details_in_num(11,3)=3;
    display_interval_times_in_ms(11,1)=2475;
    display_interval_times_in_ms(11,2)=4158;
    display_interval_times_in_ms(11,3)=5247;
    
    display_names{12} = 'ESC_Right_Niho_Initial2';
    display_details_in_num(12,1)=1;
    display_details_in_num(12,2)=4;
    display_details_in_num(12,3)=3;
    display_interval_times_in_ms(12,1)=2904;
    display_interval_times_in_ms(12,2)=4125;
    display_interval_times_in_ms(12,3)=5676;
    
    display_names{13} = 'ESC_Right_Justine_Goal1';
    display_details_in_num(13,1)=1;
    display_details_in_num(13,2)=1;
    display_details_in_num(13,3)=4;
    display_interval_times_in_ms(13,1)=2541;
    display_interval_times_in_ms(13,2)=3927;
    display_interval_times_in_ms(13,3)=4983;
    
    display_names{14} = 'ESC_Right_Justine_Goal2';
    display_details_in_num(14,1)=1;
    display_details_in_num(14,2)=2;
    display_details_in_num(14,3)=4;
    display_interval_times_in_ms(14,1)=2343;
    display_interval_times_in_ms(14,2)=4125;
    display_interval_times_in_ms(14,3)=5214;
    
    display_names{15} = 'ESC_Right_Justine_Initial1';
    display_details_in_num(15,1)=1;
    display_details_in_num(15,2)=3;
    display_details_in_num(15,3)=4;
    display_interval_times_in_ms(15,1)=2937;
    display_interval_times_in_ms(15,2)=4059;
    display_interval_times_in_ms(15,3)=4917;
    
    display_names{16} = 'ESC_Right_Justine_Initial2';
    display_details_in_num(16,1)=1;
    display_details_in_num(16,2)=4;
    display_details_in_num(16,3)=4;
    display_interval_times_in_ms(16,1)=2805;
    display_interval_times_in_ms(16,2)=3960;
    display_interval_times_in_ms(16,3)=5247;
    
    display_names{17} = 'ESC_Right_Priyanka_Goal1';
    display_details_in_num(17,1)=1;
    display_details_in_num(17,2)=1;
    display_details_in_num(17,3)=5;
    display_interval_times_in_ms(17,1)=2409;
    display_interval_times_in_ms(17,2)=4059;
    display_interval_times_in_ms(17,3)=5049;
    
    display_names{18} = 'ESC_Right_Priyanka_Goal2';
    display_details_in_num(18,1)=1;
    display_details_in_num(18,2)=2;
    display_details_in_num(18,3)=5;
    display_interval_times_in_ms(18,1)=2673;
    display_interval_times_in_ms(18,2)=4125;
    display_interval_times_in_ms(18,3)=5346;
    
    display_names{19} = 'ESC_Right_Priyanka_Initial1';
    display_details_in_num(19,1)=1;
    display_details_in_num(19,2)=3;
    display_details_in_num(19,3)=5;
    display_interval_times_in_ms(19,1)=2739;
    display_interval_times_in_ms(19,2)=4026;
    display_interval_times_in_ms(19,3)=5445;
    
    display_names{20} = 'ESC_Right_Priyanka_Initial2';
    display_details_in_num(20,1)=1;
    display_details_in_num(20,2)=4;
    display_details_in_num(20,3)=5;
    display_interval_times_in_ms(20,1)=2640;
    display_interval_times_in_ms(20,2)=4224;
    display_interval_times_in_ms(20,3)=5511;    
    
    display_names{21} = 'ESC_Left_Asia_Goal1';
    display_details_in_num(21,1)=2;
    display_details_in_num(21,2)=1;
    display_details_in_num(21,3)=1;
    display_interval_times_in_ms(21,1)=2310;
    display_interval_times_in_ms(21,2)=4125;
    display_interval_times_in_ms(21,3)=5247;
    
    display_names{22} = 'ESC_Left_Asia_Goal2';
    display_details_in_num(22,1)=2;
    display_details_in_num(22,2)=2;
    display_details_in_num(22,3)=1;
    display_interval_times_in_ms(22,1)=2409;
    display_interval_times_in_ms(22,2)=4059;
    display_interval_times_in_ms(22,3)=5148;
    
    display_names{23} = 'ESC_Left_Asia_Initial1';
    display_details_in_num(23,1)=2;
    display_details_in_num(23,2)=3;
    display_details_in_num(23,3)=1;
    display_interval_times_in_ms(23,1)=2574;
    display_interval_times_in_ms(23,2)=4059;
    display_interval_times_in_ms(23,3)=5346;
    
    display_names{24} = 'ESC_Left_Asia_Initial2';
    display_details_in_num(24,1)=2;
    display_details_in_num(24,2)=4;
    display_details_in_num(24,3)=1;
    display_interval_times_in_ms(24,1)=2706;
    display_interval_times_in_ms(24,2)=4059;
    display_interval_times_in_ms(24,3)=5544;
    
    display_names{25} = 'ESC_Left_Danyang_Goal1';
    display_details_in_num(25,1)=2;
    display_details_in_num(25,2)=1;
    display_details_in_num(25,3)=2;
    display_interval_times_in_ms(25,1)=2079;
    display_interval_times_in_ms(25,2)=3993;
    display_interval_times_in_ms(25,3)=5478;
    
    display_names{26} = 'ESC_Left_Danyang_Goal2';
    display_details_in_num(26,1)=2;
    display_details_in_num(26,2)=2;
    display_details_in_num(26,3)=2;
    display_interval_times_in_ms(26,1)=1980;
    display_interval_times_in_ms(26,2)=3993;
    display_interval_times_in_ms(26,3)=5280;
    
    display_names{27} = 'ESC_Left_Danyang_Initial1';
    display_details_in_num(27,1)=2;
    display_details_in_num(27,2)=3;
    display_details_in_num(27,3)=2;
    display_interval_times_in_ms(27,1)=2574;
    display_interval_times_in_ms(27,2)=4125;
    display_interval_times_in_ms(27,3)=5412;
    
    display_names{28} = 'ESC_Left_Danyang_Initial2';
    display_details_in_num(28,1)=2;
    display_details_in_num(28,2)=4;
    display_details_in_num(28,3)=2;
    display_interval_times_in_ms(28,1)=2211;
    display_interval_times_in_ms(28,2)=4092;
    display_interval_times_in_ms(28,3)=5049;
    
    display_names{29} = 'ESC_Left_Niho_Goal1';
    display_details_in_num(29,1)=2;
    display_details_in_num(29,2)=1;
    display_details_in_num(29,3)=3;
    display_interval_times_in_ms(29,1)=2541;
    display_interval_times_in_ms(29,2)=3993;
    display_interval_times_in_ms(29,3)=5379;
    
    display_names{30} = 'ESC_Left_Niho_Goal2';
    display_details_in_num(30,1)=2;
    display_details_in_num(30,2)=2;
    display_details_in_num(30,3)=3;
    display_interval_times_in_ms(30,1)=2475;
    display_interval_times_in_ms(30,2)=4092;
    display_interval_times_in_ms(30,3)=5412;
    
    display_names{31} = 'ESC_Left_Niho_Initial1';
    display_details_in_num(31,1)=2;
    display_details_in_num(31,2)=3;
    display_details_in_num(31,3)=3;
    display_interval_times_in_ms(31,1)=2772;
    display_interval_times_in_ms(31,2)=4059;
    display_interval_times_in_ms(31,3)=5412;
    
    display_names{32} = 'ESC_Left_Niho_Initial2';
    display_details_in_num(32,1)=2;
    display_details_in_num(32,2)=4;
    display_details_in_num(32,3)=3;    
    display_interval_times_in_ms(32,1)=2739;
    display_interval_times_in_ms(32,2)=4158;
    display_interval_times_in_ms(32,3)=5280;
    
    display_names{33} = 'ESC_Left_Justine_Goal2';
    display_details_in_num(33,1)=2;
    display_details_in_num(33,2)=2;
    display_details_in_num(33,3)=4; 
    display_interval_times_in_ms(33,1)=1782;
    display_interval_times_in_ms(33,2)=4224;
    display_interval_times_in_ms(33,3)=5544;
    
    display_names{34} = 'ESC_Left_Justine_Initial1';
    display_details_in_num(34,1)=2;
    display_details_in_num(34,2)=3;
    display_details_in_num(34,3)=4;
    display_interval_times_in_ms(34,1)=2706;
    display_interval_times_in_ms(34,2)=4059;
    display_interval_times_in_ms(34,3)=4950;

    display_names{35} = 'ESC_Left_Justine_Initial2';
    display_details_in_num(35,1)=2;
    display_details_in_num(35,2)=4;
    display_details_in_num(35,3)=4;
    display_interval_times_in_ms(35,1)=2640;
    display_interval_times_in_ms(35,2)=4158;
    display_interval_times_in_ms(35,3)=4851;
    
    display_names{36} = 'ESC_Left_Priyanka_Goal1';
    display_details_in_num(36,1)=2;
    display_details_in_num(36,2)=1;
    display_details_in_num(36,3)=5;
    display_interval_times_in_ms(36,1)=2079;
    display_interval_times_in_ms(36,2)=4026;
    display_interval_times_in_ms(36,3)=5115;
    
    display_names{37} = 'ESC_Left_Priyanka_Goal2';
    display_details_in_num(37,1)=2;
    display_details_in_num(37,2)=2;
    display_details_in_num(37,3)=5;
    display_interval_times_in_ms(37,1)=2376;
    display_interval_times_in_ms(37,2)=4092;
    display_interval_times_in_ms(37,3)=5181;
    
    display_names{38} = 'ESC_Left_Priyanka_Initial1';
    display_details_in_num(38,1)=2;
    display_details_in_num(38,2)=3;
    display_details_in_num(38,3)=5;
    display_interval_times_in_ms(38,1)=2871;
    display_interval_times_in_ms(38,2)=4059;
    display_interval_times_in_ms(38,3)=5148;
    
    display_names{39} = 'ESC_Left_Priyanka_Initial2';
    display_details_in_num(39,1)=2;
    display_details_in_num(39,2)=4;
    display_details_in_num(39,3)=5;
    display_interval_times_in_ms(39,1)=2805;
    display_interval_times_in_ms(39,2)=4092;
    display_interval_times_in_ms(39,3)=5247;
end


