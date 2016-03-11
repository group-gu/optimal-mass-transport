data_dir = 'data\';

source = 'n1.uv';
target = 'n2.uv';
[face,vertex,extra] = read_mfile([data_dir source]);
[face2,vertex2,extra2] = read_mfile([data_dir target]);

uv = extra.Vertex_uv;
uv = minimize_area_distortion(face,vertex,uv);
sigma = compute_measure(face,vertex,uv,'continuous');

uv2 = extra2.Vertex_uv;
uv2 = minimize_area_distortion(face2,vertex2,uv2);
delta2 = compute_measure(face2,vertex2,uv2);

bd2 = compute_bd(face2);
disk2 = uv2(bd2,:);

[pd2,h] = discrete_optimal_transport(disk2,face2,uv2,delta2,sigma);
wd = wasserstein_distance(disk2,pd2,sigma);

save([data_dir source '-' target '.mat'])
