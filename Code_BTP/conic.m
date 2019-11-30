function rinter = conic( r_in, e, surf )

x0 = r_in( :, 1 );
y0 = r_in( :, 2 );
z0 = r_in( :, 3 );
e1 = e( :, 1 );
e2 = e( :, 2 );
e3 = e( :, 3 );
R = surf.R(1);

    A = e2.^2 + e3.^2;
    B = e1 * R - e2 .* y0 - e3 .* z0;
    D = B.^2 - A .* ( -2 * R * x0 + y0.^2 + z0.^2 );
    D( D < 0 ) = Inf; %  mark no intersection as Inf, I is nulled below anyway
    
    d01 = ( y0.^2 + z0.^2 ) / ( 2 * R ) - x0; % distance to the intersection for the ray || to the paraboloid
    d02 = d01;

d1 = ( B + sqrt( D ) ) ./ A;
d2 = ( B - sqrt( D ) ) ./ A;

% it is necessary to eliminate infinities before the following logical operation
d1(  ~isfinite( d1 )  ) = 0;
d2(  ~isfinite( d2 )  ) = 0;
d01( ~isfinite( d01 ) ) = 0;
d02( ~isfinite( d02 ) ) = 0;

d( :, 1 ) = ( abs( A ) <= eps ) .* d01 + ( abs( A ) >  eps ) .* d1;
d( :, 2 ) = ( abs( A ) <= eps ) .* d02 + ( abs( A ) >  eps ) .* d2;

% find the shortest positive distance to the (two) intersections along the ray
d( d <= 1e-12 ) = NaN; %realmax; % intensities for these rays (non-intersecting the surface) will be set to 0 anyway

[ ~, ii ] = min( d, [], 2 );
ind = sub2ind( size( d ), ( 1:size( d, 1 ) )', ii ); % linear index of the min value
d = abs( d( ind ) );

% form the intersection vector
rinter = r_in + repmat( d, 1, 3 ) .* e;
                        
