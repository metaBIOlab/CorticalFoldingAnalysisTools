addpath("lib");                                                            % Adding the functions path
addpath(strcat("lib", filesep, "FSmatlab"));
addpath(strcat("lib", filesep, "iso2mesh"));

clear;

maindir = [cd filesep 'data' filesep];                                     % Directory where are the data files
savedir = [cd filesep 'output' filesep];                                   % Directory where you want to save the output

runFolder = true;                                                          % If you want to run all the data in maindir -> true, otherwise -> false and put the name of the files in 'ids'

if runFolder
    ids = dir(maindir);
    ids = ids(3:end);
    ids = string(struct2table(ids).name);
else                                                                       %#ok<*UNRCH>
    ids = ["sub-0001"; "sub-0002"];
end

hemispheres = ['l'; 'r'];
mkdir(strcat('.', filesep, 'temp', filesep));                              % Make a temporary folder to save the output files of the parfor

for i= 1:length(ids)

    final_out = struct();
    cnt = 1;
    GI = 1.1;

    for h = 1:length(hemispheres)
        pathname = char(strcat(maindir, ids(i), filesep, 'surf', filesep));

        for dim = logspace(1, 8.5, 75)                                     % logspace(X1,X2,N) is similar to linspace, but with a log variation between X1 and X2

            while (GI > 1)
                estimateScale(dim, pathname, hemispheres(h), savedir, 1, 1);

                outputname = [savedir filesep 'VoxelisationVol_scale=' num2str(dim) '_hemi=' hemispheres(h) '.mat'];
                FileData = load(outputname);

                final_out(cnt).subj = ids(i);
                final_out(cnt).TotalArea = FileData.output.mesh_area_pial;
                final_out(cnt).ExposedArea = FileData.output.mesh_area_CHFull;
                final_out(cnt).GMvol = FileData.output.volume_GM;
                final_out(cnt).WMarea = FileData.output.mesh_area_white;
                final_out(cnt).WMareaFull = FileData.output.mesh_area_whiteFull;
                final_out(cnt).scale = dim;
                final_out(cnt).hemisphere = string(hemispheres(h));

                GI = final_out(cnt).TotalArea / final_out(cnt).ExposedArea;
                cnt = cnt + 1;
            end
        end
    end

    final_out = struct2table(final_out);

    if ~isempty(final_out)                                                 % Writing a temp file with output of the ids data from this parfor iteration
        writetable(final_out, ...
            strcat('.', filesep, 'temp', filesep, ids(i), '.csv'));
    end

end

output_file = strcat('.', filesep, 'scales_morphometry.csv');              % Joining temp files from the parfor iterations
directory = strcat('.', filesep, 'temp', filesep);
file_type = '*.csv';

joinFilesParfor(output_file, directory, file_type)
