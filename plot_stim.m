function elapsed = plot_stim(X, Fs)

plottime = tic;

    figure( 1 ); 
    clf
    axes( 'position', [ 0.13         0.51      0.73119      0.34116 ] );

    plot( [1:size(X,1)]/Fs, X )
    ylim( [ 0 5 ] )
    xlim( [ 1 size(X, 1) ] / Fs )

    axes( 'position', [ 0.13         0.11      0.7800      0.34116 ] );
    imagesc( [1:size(X,1)]/Fs, 1:size(X,2), X', [ 0 5 ] ), axis xy
    xlabel( 'Time (sec)' )
    colorbar('EastOutside');

elapsed = toc(plottime);

end
