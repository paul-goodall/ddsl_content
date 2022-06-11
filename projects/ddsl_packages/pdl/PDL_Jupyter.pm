#!/usr/bin/perl

use PDL;
use PGPLOT;               
use PDL::Graphics::Simple;
use PDL::Graphics::PGPLOT;
use PDL::Graphics::PGPLOT::Window;

$ENV{PGPLOT_XW_WIDTH}=0.3;
dev('/XSERVE');





1;