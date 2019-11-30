%this is a main function for parabolic case. Change collimated from source
%to get parallel rays from infinite.
function main()

% create a container for the rays and mirror
bench = Path;

lens1 = Parabola( [ 60 0 0 ], 52.5, 40, -1 );
lens1.rotate([0 0 1], pi);
bench.append(lens1);

mirror1 = Plane( [ 0 0 0 ], 100, 100); 
mirror1.rotate( [ 0 0 1 ], -pi / 4 );
bench.append( mirror1 );


%mirror2 = Plane( [ 40 -50 0 ], 40, 40 ); 
%mirror2.rotate( [ 0 0 1 ], -pi / 4 );
%bench.append( mirror2 );

%use source for point source and collimated for parallel rays
nrays = 500;

%ray of hexagon less than 500 rays is being created here. with redius of
%10. If changing to collimated change 10 to higherr vale radius to about 58
%or 60. Here 000 is starting location anf 100 is the direction for x axis
%where ray's normal lies. 

rays_in = Rays( nrays, 'source', [ 0 0 0 ], [ 1 0 0 ], 10, 'hexagonal' );


fprintf( 'Tracing rays...\n' );

%bench.trace is used to trace the ray and append the newly created rays after intersection of rays with objects i.e. parabola or mirror 
rays_through = bench.trace( rays_in );

%here clines can be changed to lines or rays
bench.draw( rays_through, 'clines', []);

end
