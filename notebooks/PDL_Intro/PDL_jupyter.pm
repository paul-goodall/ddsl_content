#!/usr/bin/perl

use PDL;
use DATA::DUMPER;
use PDL::NiceSlice;
use PDL::Transform;
use PDL::Fit::Gaussian;
use PDL::Graphics::LUT;
use PDL::Fit::Polynomial;
use PDL::Graphics::PGPLOT::Window;

# Extra Modules
use PGPLOT;               
use Data::Dumper;
use Warnings;