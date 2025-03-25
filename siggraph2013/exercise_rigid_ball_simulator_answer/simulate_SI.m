function [config ,dt] = simulate_SI(config, info, dt)

%--- Extract data form structures -- for readability only
X  = config.X;
Y  = config.Y;
Vx = config.Vx;
Vy = config.Vy;
Fx = config.Fx;
Fy = config.Fy;
w  = config.W;
R = config.R;

%--- Filter proximity info to only contain relevant contact information
idx = info.D <= 0.01;
O   = info.O(  idx==1,:);
Nx  = info.Nx( idx==1,:);
Ny  = info.Ny( idx==1,:);
D   = info.D(  idx==1,:);

cX  = info.X( idx==1,:);
cY  = info.Y( idx==1,:);

Pn  = info.Pn( idx==1,:);

%--- Setup contact force problem

C      = length(D);   % Number of contacts

k_allowedPenetration = 0.001;
k_biasFactor = 0.2;
accumulateImpulses = 1;
massNormal= zeros(C,1);
if( C>0)
    for c=1:C  %prestep
        a = O(c,1);
        b = O(c,2);
        r1 = [cX(c)-X(a),cY(c)-Y(a)];
        r2 = [cX(c)-X(b),cY(c)-Y(b)];
        normal = -[Nx(c),Ny(c)];
        rn1 = dot(r1,normal);
        rn2 = dot(r2,normal);
        kNormal = w(a)+w(b);
        invI1 = 2*w(a)/R(a)/R(a);
        invI2 = 2*w(b)/R(b)/R(b);
        kNormal = kNormal+invI1*(dot(r1,r1)-rn1*rn1)+invI2*(dot(r2,r2)-rn2*rn2);
        massNormal(c) = 1/kNormal;

        %accumulateImpulses
        PnTemp = Pn(c)*normal;
        Vx(a) = Vx(a) - w(a).*(PnTemp(1));
        Vy(a) = Vy(a) - w(a).*(PnTemp(2));

        Vx(b) = Vx(b) + w(b).*(PnTemp(1));
        Vy(b) = Vy(b) + w(b).*(PnTemp(2));
    end

    for c=1:C  %ApplyImpulse
        a = O(c,1);
        b = O(c,2);
        normal = -[Nx(c),Ny(c)];
        separation = R(a)+R(b)-norm([X(a)-X(b),Y(a)-Y(b)]);
        dv = [Vx(b,:)-Vx(a,:),Vy(b,:)-Vy(a,:)];
        vn = dot(dv,normal);
        bias = -k_biasFactor * 1/dt * min(0.0, -separation + k_allowedPenetration);
        dPn = massNormal(c)*(-vn + bias);

        %accumulateImpulses
        if accumulateImpulses
            Pn0 = Pn(c);
            Pn(c) = max(Pn0 + dPn,0.0);
            dPn = Pn(c)-Pn0;
        else
            dPn = max(dPn, 0.0);
        end

        Pntemp = dPn*normal;
        Vx(a) = Vx(a) - w(a).*(Pntemp(1));
        Vy(a) = Vy(a) - w(a).*(Pntemp(2));

        Vx(b) = Vx(b) + w(b).*(Pntemp(1));
        Vy(b) = Vy(b) + w(b).*(Pntemp(2));
    end
end



%--- Velocity update
Vx = Vx + dt* w.*Fx;
Vy = Vy + dt* w.*Fy;

%--- Position update
X = X + dt*Vx;
Y = Y + dt*Vy;

%--- Store new values in config object
config.X  = X;
config.Y  = Y;
config.Vx = Vx;
config.Vy = Vy;

end
