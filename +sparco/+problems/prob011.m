function data = prob011(varargin)
%PROB011  Gaussian ensemble, Gaussian spikes.
%
%   PROB011 creates a problem structure.  The generated signal will
%   consist of K = 32 sign spikes and have length N = 1024. The
%   signal is measured using an M = 256 by N Gaussian ensemble.
%
%   The following optional arguments are supported:
%
%   PROB011('k',K,'m',M,'n',N,'scale',SCALE,flags) is the same as
%   above, but with a measurement matrix of size SCALE*M by SCALE*N
%   and a signal length of SCALE*N. The number of spikes in the signal
%   is set to SCALE*K. When scale is not an integer, all parameters are
%   rounded to the nearest integer after scaling. By default, the SCALE
%   is set to 1. The 'noseed' flag can be specified to suppress
%   initialization of the random number generators. Each of the
%   parameter pairs and flags can be omitted.
%
%   Examples:
%   P = prob011;  % Creates the default 011 problem.
%
%   See also GENERATEPROBLEM.
%
%MATLAB SPARCO Toolbox.

% 23 Jul 09: Updated to use Spot operators.
%
%   Copyright 2008, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: prob011.m 1517 2009-09-26 02:57:28Z ewout78 $

% Parse parameters and set problem name
[opts,varg] = parseDefaultOpts(varargin);
[parm,varg] = parseOptions(varg,{'noseed'},{'k','m','n','scale'});
scale       = getOption(parm,'scale', 1);
k           = getOption(parm,'k',    32);
m           = getOption(parm,'m',   256);
n           = getOption(parm,'n',  1024);
info.name   = 'gausspike';

% Return problem name if requested
if opts.getname, data = info.name; return; end

% Initialize random number generators
if ~parm.noseed, randn('state',0); rand('state',0); end

% Problem dimensions
k         = max(1,round(k * scale));
m         = max(1,round(m * scale));
n         = max(1,round(n * scale));
p         = randperm(n); p = p(1:k);

% Generate signal
signal    = zeros(n,1);
signal(p) = randn(k,1);

% Measurement operator. (Dirac sparsity basis.)
G = opGaussian(m,n);

% Set up the problem
data.signal      = signal;
data.M           = G;
data.x0          = data.signal;
data.b           = G * data.x0;
data.r           = zeros(size(data.b));
data             = completeOps(data);

% ======================================================================
% The following is self-documentation code, and is optional.
% ======================================================================

% Additional information
info.title           = 'Gaussian spikes, real domain';
info.thumb           = 'figProblem011';
info.citations       = {};
info.fig{1}.title    = 'Spike signal';
info.fig{1}.filename = 'figProblem011Signal';

% Set the info field in data
data.info = info;

% Plot figures
if opts.update || opts.show
  figure(opts.figno); opts.figno = opts.figno + opts.figinc;
  plot(1:n,data.signal,'b-');
  xlim([1,n]); ylim([-1.2,1.2]);
  updateFigure(opts, info.fig{1}.title, info.fig{1}.filename)
  
  if opts.update
     P = ones(128,128,3);
     P = thumbPlot(P,1:n,data.signal,[0,0,1]);
     P = (P(1:2:end,:,:) + P(2:2:end,:,:)) / 2;
     P = (P(:,1:2:end,:) + P(:,2:2:end,:)) / 2;
     thumbwrite(P, info.thumb, opts);
  end
end