function H = calculate_hessian(cp,pd,mu)
nc = size(pd.cell,1);
ne = (sum(cellfun(@length,pd.cell))-nc);
I = zeros(ne,1);
J = zeros(ne,1);
V = zeros(ne,1);
k = 1;
for i = 1:nc
    ci = pd.cell{i};
    for j = 1:length(ci)-1
        I(k) = ci(j);
        J(k) = ci(j+1);
        V(k) = i;
        k = k+1;
    end
end
C = sparse(I,J,V);
[I,J,~] = find(C);
I2 = zeros(ne,1);
J2 = zeros(ne,1);
V2 = zeros(ne,1);
k = 1;
in = inpolygon(pd.dpe(:,1),pd.dpe(:,2),cp(:,1),cp(:,2));
for i = 1:length(I)
    I2(k) = C(I(i),J(i));
    J2(k) = C(J(i),I(i));
    % compute edge length in convex polygon
    p1 = pd.dpe(I(i),:);
    p2 = pd.dpe(J(i),:);
    in2 = in([I(i) J(i)]);
    if I2(k) == 6073
%         pause
    end
    switch sum(in2)
        case 2 % if both points in polygon
            lij = norm(p1-p2);
        case 1 % if one point inside, one outside
            try                
                pi = intersectEdgePolygon([p1,p2],cp);                
            catch ex
                save hessian
                pause
            end
            if length(p1) ~= length(pi)
                pi
            end
            if in2(1)
                lij = norm(pi-p1);
            else
                lij = norm(pi-p2);
            end
        case 0 % both point outside the polygon
            lij = 0;
    end
    mu_k = ((mu(I2(k))+mu(J2(k)))/2);
    V2(k) = -lij*mu_k/norm(pd.uv(I2(k),:)-pd.uv(J2(k),:));
    k = k+1;
end
H = sparse(I2,J2,V2);
Hs = -sum(H,2);
% ind = Hs==0; % some cell may be out of domain
% Hs(ind) = 1;
H = H + sparse(diag(Hs));