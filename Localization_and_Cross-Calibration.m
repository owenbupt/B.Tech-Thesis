%This code predicts location after cross-calibration on points found by recursive bagging.
%Finally predicts location using the Localization Algorithm

clc;
clear all;


[num,txt,raw]=xlsread('./../Dataset/Acad_14n15oct_shweta.csv'); %
[r,c]=size(raw);
bssid=unique(txt(2:r,7));
for i=1:r-1
    txt{i+1,5}=num2str(num(i,4));
    if ~(isnan(num(i,1)))
        txt{i+1,2}=num2str(num(i,1));
    end
end

for i=1:size(bssid,1)
    row=find(strcmp({txt{1:r,7}},bssid(i,1)));
    unique_loc=unique(txt(row(1,:),2));
    unique_loc_len=length(unique_loc);
    values=zeros(length(row),1); %all values for a given bssid and given location
    medians=zeros(31,1); %
    freq=zeros(31,1); %to keep track of places with no value
    
    for j=1:unique_loc_len
        freq(str2num(cell2mat(unique_loc(j))),1)=1;
        unique_row= find(strcmp({txt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
        values_in_cell=txt(row(1,unique_row),5);
        for k=1:length(values_in_cell)
            values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
        end
        values=values(1:length(values_in_cell));
        medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
    end
    
    for j=2:32
        if(freq(j-1)~=0)
            bssid(i,j)={medians(j-1)};
        else
           bssid(i,j)={inf};
        end
    end
end

[testnum,testtxt,testraw]=xlsread('./../Dataset/Acad_14n15oct_geetali.csv'); %TESTDATA floor file with 3-4 wings each
[testr,testc]=size(testtxt);
testbssid=unique(testtxt(2:testr,7));
for i=1:testr-1
    testtxt{i+1,5}=num2str(testnum(i,4));
    if ~(isnan(testnum(i,1)))
        testtxt{i+1,2}=num2str(testnum(i,1));
    end
end

for i=1:size(testbssid,1)
    row=find(strcmp({testtxt{1:testr,7}},testbssid(i,1)));
    sum=zeros(31,1); %
    unique_loc=unique(testtxt(row(1,:),2));
    unique_loc_len=length(unique_loc);
    values=zeros(length(row),1); %all values for a given bssid and given location
    medians=zeros(31,1); %
    freq=zeros(31,1); %
    
    for j=1:unique_loc_len
        freq(str2num(cell2mat(unique_loc(j))),1)=1;
        unique_row= find(strcmp({testtxt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
        values_in_cell=testtxt(row(1,unique_row),5);
        for k=1:length(values_in_cell)
            values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
        end
        values=values(1:length(values_in_cell));
        medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
    end
    
    for j=2:32
        if(freq(j-1)~=0)
           testbssid(i,j)={medians(j-1)};
        else
           testbssid(i,j)={inf};
        end
    end
end
%}

common=intersect(bssid(:,1),testbssid(:,1));
points=[4,7,12,18,26];  %5 downsampling (obtained from recursive bagging)

len=length(intersect(bssid(:,1),testbssid(:,1)));
X=zeros(1,len);
Y=zeros(1,len);
j=1;
    for k=1:length(points)
        pos=points(k)+1;
        for i=1:len
            testrow=find(strcmp({testbssid{:,1}},common(i)));
            row=find(strcmp({bssid{:,1}},common(i)));
            a=cell2mat(testbssid(testrow,pos));
            b=cell2mat(bssid(row,pos));
            if(a~=inf && b~=inf)
                X(j)=a;
                Y(j)=b;
                j=j+1;
            end
        end
    end
    
s=scatter(X,Y);
s.LineWidth = 0.6;
s.MarkerEdgeColor = 'b';
s.MarkerFaceColor = [0 0.5 0.5];
xlabel('Geetali phone RSSI');
ylabel('Shweta phone RSSI');
title('Distribution of RSSI points for Calibration'); %Cross-Calibration Graph of phones to fit a line
P = polyfit(X,Y,1);
yfit = P(1)*X+P(2);
hold on;
plot(X,yfit,'r-.');

slope=P(1); %Of the found equation
intercept=P(2); %Of the found equation

% Reading test data for prediction
[gitnum,gittxt,gitraw]=xlsread('./../Dataset/Test_october_1n7_nearby.csv');
[testr,testc]=size(gittxt);
for i=1:testr-1
    gittxt{i+1,5}=num2str(gitnum(i,4));
    if ~(isnan(gitnum(i,1)))
        gittxt{i+1,2}=num2str(gitnum(i,1));
    end
end

no_of_blocks=unique(gitnum(1:testr-1,1));
breadth=length(no_of_blocks);

for outer=1:breadth %Each floor block wise iteration
    block_no=no_of_blocks(outer);
    start=min(find(gitnum(:,1)==block_no))+1;
    stop=max(find(gitnum(:,1)==block_no))+1;
    gitbssid=unique(gittxt(start:stop,7));
    dis=zeros(1,1);
    for i=1:size(gitbssid,1)
        row=find(strcmp({gittxt{1:testr,7}},gitbssid(i,1)));       
        unique_loc=unique(gittxt(row(1,:),2));
        unique_loc_len=length(unique_loc);
        values=zeros(length(row),1); %all values for a given bssid and given location
        medians=zeros(31,1); %
        freq=zeros(31,1); %
        
        for j=1:unique_loc_len
            freq(str2num(cell2mat(unique_loc(j))),1)=1;
            unique_row= find(strcmp({gittxt{row(1,:),2}},unique_loc(j))); %find row numbers for all values for given unique location
            values_in_cell=gittxt(row(1,unique_row),5);
            for k=1:length(values_in_cell)
                values(k,1)=str2num(cell2mat(values_in_cell(k,1)));
            end
            values=values(1:length(values_in_cell));
            medians(str2num(cell2mat(unique_loc(j))),1)=median(values);
        end
        for j=2:32 %TESTDATA
            if(freq(j-1)~=0)
                gitbssid(i,j)={P(1)*medians(j-1)+P(2)}; %With median
            else
                 gitbssid(i,j)={inf};
            end
        end
    end

        pos=-1;
        k=1;
        for i=1:size(gitbssid,1)
            mini=10000;
            pos=-1;
            for j=2:32 %
                row=find(strcmp({gitbssid{i,1}},bssid(:,1)));
                if(length(row)~=0)
                    a=cell2mat(bssid(row,j));
                    b=cell2mat(gitbssid(i,no_of_blocks(outer)+1));
                    if(a~=inf && b~=inf)
                        if(abs(a-b)<mini)
                            mini=abs(a-b);
                            pos=j-1;
                        end
                    end
                end
            end
            if(pos~=-1)
                dis(k)=pos;
                k=k+1;
            end
        end
        if(length(dis)~=0)
            disp(['Floor/Wing Wing wise prediction is ' num2str(mode(dis))]); % prediction of location
        else
            disp('Location not found');
        end
        
        if(length(dis)~=0)
            add=zeros(1,31);
            add(block_no)=1;
            toadd = add;
            dlmwrite ('./../Accuracy_Dataset/dbm/Achieve_newtrial3_5_points.csv', toadd, '-append' );

            add=zeros(1,31);
            add(mode(dis))=1;
            toadd = add;
            dlmwrite ('./../Accuracy_Dataset/dbm/Obtained_newtrial3_5_points.csv', toadd, '-append' );
        end
        
end
disp('groundfloorcdxcounter 1 ; groundfloorglassroom 2 ; groundfloorlobby 3 ; groundfloorclassroomlobby 4 ; firstfloorA 5 ; firstfloorB 6 ; firstfloorlobby 7');
disp('firstfloorclassroomlobby 8 ; secondfloorA 9 ; secondfloorB 10 ; secondfloorlobby 11 ; secondfloorclassroomlobby 12 ; thirdfloorA 13 ; thirdfloorB 14');
disp('thirdfloorlobby 15 ; fourthfloorA 16 ; fourthfloorB 17 ; fourthfloorlobby 18 ; fifthfloorA 19 ; fifthfloorB 20 ; fifthfloorlobby 21');
disp('C01 22 ; C02 23 ; C03 24 ; C11 25 ; C12 26 ; C13 27 ; C21 28 ; C22 29 ; C23 30 ; C24 31');
