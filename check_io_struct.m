function io = check_io_struct(io)

if DEBUG disp('== Performing sloppy io-struct integrity check...'); end

if isstruct(io)
        if isempty( io.Fs ), io.Fs = 25000; end
        if isempty( io.inputchans ), io.inputchans = [1 2 3 4]; end % channel number
        if isempty( io.outputchans ), io.outputchans = [9 10 11 12]; end % channel number

    elseif ischar(io)
        if DEBUG disp(['    Loading template: ', io]); end
        io = load_template('io', io);

    else
        error('Io-substruct has unknown format! (Proper struct or template name expected');
end

if DEBUG disp(['   Clear!', 10]); end

end
    