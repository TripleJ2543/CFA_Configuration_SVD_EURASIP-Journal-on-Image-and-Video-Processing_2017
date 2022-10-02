%% Reset
clear all
close all
clc

%% Input Image
[FileName, PathName] = uigetfile({'*.jpg;*.tif;*.png;*.gif;*.bmp','All Image Files';'*.*','All Files' },'Open File', pwd);
Prompt = {'Block Size (32, 64, 128, 256, 512):'};
DlgTitle = 'Input Values';
NumLines = 1;
def = {'512'};
answer = inputdlg(Prompt,DlgTitle,NumLines,def);

InputImage = double(imread([PathName FileName]));
blocksize = str2num(answer{1});
[M, N, ~]=size(InputImage);
centerM = floor(M/2);
centerN = floor(N/2);

%% Feature Extraction
CenterImage = InputImage(centerM - blocksize/2 + 1:centerM + blocksize/2, centerN - blocksize/2 + 1:centerN + blocksize/2, :);
cut = blocksize*(1/4) ;

CenterR = CenterImage(:,:,1);
CenterG = CenterImage(:,:,2);
CenterB = CenterImage(:,:,3);

% Red
CenterR1 = CenterR(1:2:blocksize, 1:2:blocksize);
CenterR2 = CenterR(1:2:blocksize, 2:2:blocksize);
CenterR3 = CenterR(2:2:blocksize, 1:2:blocksize);
CenterR4 = CenterR(2:2:blocksize, 2:2:blocksize);
% Green
CenterG1 = CenterG(1:2:blocksize, 1:2:blocksize);
CenterG2 = CenterG(1:2:blocksize, 2:2:blocksize);
CenterG3 = CenterG(2:2:blocksize, 1:2:blocksize);
CenterG4 = CenterG(2:2:blocksize, 2:2:blocksize);
% Blue
CenterB1 = CenterB(1:2:blocksize, 1:2:blocksize);
CenterB2 = CenterB(1:2:blocksize, 2:2:blocksize);
CenterB3 = CenterB(2:2:blocksize, 1:2:blocksize);
CenterB4 = CenterB(2:2:blocksize, 2:2:blocksize);

% inter channel
GR1 = CenterG1 - CenterR1;
GR2 = CenterG2 - CenterR2;
GR3 = CenterG3 - CenterR3;
GR4 = CenterG4 - CenterR4;

GB1 = CenterG1 - CenterB1;
GB2 = CenterG2 - CenterB2;
GB3 = CenterG3 - CenterB3;
GB4 = CenterG4 - CenterB4;

% SVD
SingularGR1 = svd(GR1);
SingularGR2 = svd(GR2);
SingularGR3 = svd(GR3);
SingularGR4 = svd(GR4);

SingularGB1 = svd(GB1);
SingularGB2 = svd(GB2);
SingularGB3 = svd(GB3);
SingularGB4 = svd(GB4);

SumGR1 = sum(SingularGR1(cut:end));
SumGR2 = sum(SingularGR2(cut:end));
SumGR3 = sum(SingularGR3(cut:end));
SumGR4 = sum(SingularGR4(cut:end));

SumGB1 = sum(SingularGB1(cut:end));
SumGB2 = sum(SingularGB2(cut:end));
SumGB3 = sum(SingularGB3(cut:end));
SumGB4 = sum(SingularGB4(cut:end));

%% Classification
if (abs(SumGR1 - SumGR4 + SumGB4 - SumGB1) > abs(SumGR2 - SumGR3+SumGB3 - SumGB2)) ...
        && ( SumGR1 + SumGB4  > SumGR4 + SumGB1  ) %% RGGB
    disp('pattern: RGGB')
    pattern = 'RGGB';
elseif (abs(SumGR1 - SumGR4 + SumGB4 - SumGB1) > abs(SumGR2 - SumGR3+SumGB3 - SumGB2)) ...
        && ( SumGR1 + SumGB4  < SumGR4 + SumGB1  ) %% BGGR
    disp('pattern: BGGR')
    pattern = 'BGGR';
elseif (abs(SumGR1 - SumGR4 + SumGB4 - SumGB1) < abs(SumGR2 - SumGR3+SumGB3 - SumGB2)) ...
        &&( SumGR2 + SumGB3  > SumGR3 + SumGB2  ) %% GRBG
    disp('pattern: GRBG')
    pattern = 'GRBG';
elseif (abs(SumGR1 - SumGR4 + SumGB4 - SumGB1) < abs(SumGR2 - SumGR3+SumGB3 - SumGB2)) ...
        &&( SumGR2 + SumGB3  < SumGR3 + SumGB2  ) %% GBRG
    disp('pattern: GBRG')
    pattern = 'GBRG';
end

msgbox(['Bayer Pattern: ' pattern]);