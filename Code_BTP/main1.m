function main1()

bench = Path;


mirror1 = Plane( [ 60 0 0 ], 40, 40 ); 
mirror1.rotate( [ 0 0 1 ], -pi / 4 );
bench.append( mirror1 );

% mirror2 = Plane( [ 60 50 0 ], 40, 40 ); % pay attention to the glass order here!
% mirror2.rotate( [ 0 0 1 ], -pi / 4 );
% bench.append( mirror2 );

nrays = 500;
rays_in = Rays( nrays, 'collimated', [ 0 0 0 ], [ 1 0 0 ],58 , 'hexagonal' );

fprintf( 'Tracing rays...\n' );
rays_through = bench.trace( rays_in,1 );


bench.draw( rays_through, 'clines', [] ); 

end
