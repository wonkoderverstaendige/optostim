function elapsed = plot_stim(X, Fs)

plottime = tic;

    % plot
    figure( 1 ); 
    clf
    ah1 = axes( 'position', [ 0.13         0.51      0.73119      0.34116 ] );

    plot( [1:size(X,1)]/Fs, X )
    ylim( [ 0 5 ] )
    xlim( [ 1 size(X, 1) ] / Fs )
    %subplot( 2, 1, 2 )
    ah2 = axes( 'position', [ 0.13         0.11      0.78519      0.34116 ] );
    imagesc( [1:size(X,1)]/Fs, 1:size(X,2), X', [ 0 5 ] ), axis xy
    xlabel( 'Time (sec)' )
    colorbar

elapsed = toc(plottime);

end
