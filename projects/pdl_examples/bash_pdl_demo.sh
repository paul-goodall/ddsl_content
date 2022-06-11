#!/usr/bin/perl

use PDL;
use PGPLOT;
use PDL::Graphics::Simple;
use PDL::Graphics::PGPLOT::Window;

my $im = sin(rvals(200,200)+1);

my $nx = $im->dim(0);
my $ny = $im->dim(1);
my $LLx = 400;
my $LLy = $LLx*$ny/$nx;
my $win_frac = 0.5;
$winoptions3->{dev} ='/xs';
$winoptions3->{axis}='[BCINST,BCINST]';	
$winoptions3->{axiscolour}=1;
$winoptions3->{align}='CC';
$winoptions3->{JUSTIFY}=0;
$winoptions3->{WindowXSize}=($win_frac*$Lx);
$winoptions3->{WindowYSize}=($win_frac*$Ly);
$winoptions3->{NXPANEL}=$n_columns;
$winoptions3->{NYPANEL}=$n_rows;
$winoptions3->{Unit}='mm';
$winoptions3->{DrawWedge}=1;
$winoptions3->{CharSize}=0.7;
$winoptions3->{Colour}=4;
$winoptions3->{WindowXSize}=$win_frac*$LLx;
$winoptions3->{WindowYSize}=$win_frac*$LLy;
$win3 = PDL::Graphics::PGPLOT::Window->new($winoptions3);
pgscr(1,0,0,0);
pgscr(0,1,1,1);
my $dummy = rvals 1000,1000;
$dummy = max($dummy) - $dummy;
$win3->imag($im,{TITLE=>'STARTUP WINDOW'});
$win3->hold;
while(!<>){}



