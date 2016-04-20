# Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;

use Test::More;
use Test::Exception;
use FindBin qw($Bin);

use lib $Bin;
use VEPTestingConfig;
my $test_cfg = VEPTestingConfig->new();

my ($vf, $tmp, $expected);

## BASIC TESTS
##############

# use test
use_ok('Bio::EnsEMBL::VEP::Parser::VEP_input');

# need to get a config object for further tests
use_ok('Bio::EnsEMBL::VEP::Config');

my $cfg = Bio::EnsEMBL::VEP::Config->new();
ok($cfg, 'get new config object');

my $p = Bio::EnsEMBL::VEP::Parser::VEP_input->new({
  config => $cfg, file => $test_cfg->create_input_file([qw(21 25587759 25587759 C/A + test)])
});
ok($p, 'new is defined');

is(ref($p), 'Bio::EnsEMBL::VEP::Parser::VEP_input', 'check class');



## FORMAT TESTS
###############

$vf = Bio::EnsEMBL::VEP::Parser::VEP_input->new({
  config => $cfg, file => $test_cfg->create_input_file([qw(21 25587759 25587759 C/A + test)])
})->next();
delete($vf->{adaptor});
is_deeply($vf, bless( {
  'chr' => '21',
  'strand' => '1',
  'variation_name' => 'test',
  'map_weight' => 1,
  'allele_string' => 'C/A',
  'end' => '25587759',
  'start' => '25587759'
}, 'Bio::EnsEMBL::Variation::VariationFeature' ), 'basic next test');

$vf = Bio::EnsEMBL::VEP::Parser::VEP_input->new({
  config => $cfg, file => $test_cfg->create_input_file([qw(21 25587759 25587759 C/A - test)])
})->next();
delete($vf->{adaptor});
is_deeply($vf, bless( {
  'chr' => '21',
  'strand' => '-1',
  'variation_name' => 'test',
  'map_weight' => 1,
  'allele_string' => 'C/A',
  'end' => '25587759',
  'start' => '25587759'
}, 'Bio::EnsEMBL::Variation::VariationFeature' ), 'negative strand');

$vf = Bio::EnsEMBL::VEP::Parser::VEP_input->new({
  config => $cfg, file => $test_cfg->create_input_file([qw(21 25587759 25587759 C/A)])
})->next();
delete($vf->{adaptor});
is_deeply($vf, bless( {
  'chr' => '21',
  'strand' => '1',
  'variation_name' => undef,
  'map_weight' => 1,
  'allele_string' => 'C/A',
  'end' => '25587759',
  'start' => '25587759'
}, 'Bio::EnsEMBL::Variation::VariationFeature' ), 'stubby');

$vf = Bio::EnsEMBL::VEP::Parser::VEP_input->new({
  config => $cfg, file => $test_cfg->create_input_file([qw(21 25587759 25587769 DUP + test)])
})->next();
delete($vf->{adaptor});
is_deeply($vf, bless( {
  'chr' => '21',
  'strand' => '1',
  'variation_name' => 'test',
  'class_SO_term' => 'duplication',
  'end' => '25587769',
  'start' => '25587759'
}, 'Bio::EnsEMBL::Variation::StructuralVariationFeature' ), 'SV dup');


done_testing();