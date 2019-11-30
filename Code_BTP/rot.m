function v_rot = rot( v, k, theta )
[ m,n ] = size( v );
k = k / norm( k ); % normalize rotation axis
k = repmat( k, m, 1 );
v_rot = v .* cos( theta ) + cross( k, v, 2 ) .* sin( theta ) + k .* repmat( dot( k, v, 2 ), 1, 3 ) .* ( 1 - cos( theta ) );
end