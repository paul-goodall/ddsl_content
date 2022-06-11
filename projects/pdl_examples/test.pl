
use PDL;
use PGPLOT;               
use PDL::Graphics::Simple;
use PDL::Graphics::PGPLOT;
use PDL::Graphics::PGPLOT::Window;

use PDL::Graphics::LUT;

$im = rfits("/home/rstudio/notebooks/PDL_Intro/m51_raw.fits");

my $win_frac = 0.02;
my $nx = $im->dim(0);
my $ny = $im->dim(1);
my $LLx = 400;
my $LLy = $LLx*$ny/$nx;

$winoptions->{dev} ='/xs';
$winoptions->{WindowXSize}=$win_frac*$LLx;
$winoptions->{WindowYSize}=$win_frac*$LLy;
$win = PDL::Graphics::PGPLOT::Window->new($winoptions);
$win->ctab( lut_data('heat',0,'expo') );
$win->imag($im,{TITLE=>'Image of m51'});
$win->hold;
while(!<>){}
