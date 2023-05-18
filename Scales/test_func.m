addpath("lib");
addpath(strcat("lib",filesep,"FSmatlab"));
addpath(strcat("lib",filesep,"iso2mesh"));

clear

maindir= '/mnt/4T/AOMIC-PIOP1/freesurfer/';
savedir = '/mnt/4T/AOMIC-PIOP1/freesurfer/Scale/';

ids = ["sub-0001";"sub-0002"];

hemispheres = ['l';'r'];

for i= 1:length(ids)

    final_out = struct();
    cnt = 1;
    GI = 1.1;

    for h=1:length(hemispheres)
        pathname = char(strcat(maindir,ids(i),'/surf/'));
        %for dim = 1:0.1:8.5
        for dim = 1.3.^(-1:0.15:8)-0.27
%         for j = 5:80
%             dim = j/10+0.5;
            while (GI > 1)
            estimateScale(dim,pathname,hemispheres(h),savedir,1,1);
            outputname=[savedir '/VoxelisationVol_scale=' num2str(dim) '_hemi=' hemispheres(h) '.mat'];
            FileData = load(outputname);
            final_out(cnt).subj=ids(i);
            final_out(cnt).TotalArea=FileData.output.mesh_area_pial;
            final_out(cnt).ExposedArea=FileData.output.mesh_area_CHFull;
            final_out(cnt).GMvol=FileData.output.volume_GM;
            final_out(cnt).WMarea=FileData.output.mesh_area_white;
            final_out(cnt).WMareaFull=FileData.output.mesh_area_whiteFull;
            final_out(cnt).scale=dim;
            final_out(cnt).hemisphere=string(hemispheres(h));
            GI = final_out(cnt).TotalArea/final_out(cnt).ExposedArea;
            cnt=cnt+1;
            end
        end
    end

    if ~isempty(output)
    writetable(final_out, ...
        strcat('.', filesep, 'temp', filesep, string(i), '.csv'));
    end

end

output_file = ...
    strcat('.', filesep, 'scales_morphometry.csv');  % Joining temp files from the parfor iterations
directory = './temp/';
file_type = '*.csv';

joinFilesParfor(output_file, directory, file_type)

%save('scales_Morphometry.mat','final_out')
%writetable(struct2table(final_out), 'scales_morphometry.csv')

% para escalas em log x=1.3.^(-1:0.15:8)-0.27
% plot(x,x.^2,'o')
% loglog(x,x.^2,'o')