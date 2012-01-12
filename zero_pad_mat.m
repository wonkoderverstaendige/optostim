function X = zero_pad_mat(X, io)

if isfield(io, 'padding') && ~isempty(io.padding)
    if DEBUG disp('Channel padding received.'); end

    % only pad if requested padding channel outside boundaries of input
    % channels, else it will be overwritten later anyway
    if min(io.padding) < min(io.inputchans)
        lpad = min([io.padding io.inputchans]);
    else
        lpad=[];
    end
        
    if max(io.padding) > max(io.inputchans)
        rpad = max(io.inputchans+1):max([io.padding io.inputchans]);
    else
        rpad = [];
    end
    
    % overlapping channels are replaced with zeros
    X(:, intersect(io.inputchans, io.padding)) = 0;
    
else
    % defaults to all channels from [1-first input last+1]
    if DEBUG disp('Channel defaulted to [1:first last+1].'); end
    if min(io.inputchans) <= 1
        lpad = [];
    else
        lpad = 1:min(io.inputchans);
    end
    rpad = max(io.inputchans)+1;
end

X = [zeros(size(X, 1), numel(lpad)) X zeros(size(X, 1), numel(rpad))];
end