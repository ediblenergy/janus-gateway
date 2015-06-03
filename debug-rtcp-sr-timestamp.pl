use strictures 2;
use JSON::MaybeXS;
use DateTime;
use Text::ASCIITable;

my $ntp_epoch = DateTime->new( time_zone => 'UTC', year => 1900 )->epoch;

my $denominator = 2**32;

sub ntp_lsw_to_decimal {
    my $num = shift;
    return ( $num - .5 ) / 2**32;
}
my $json  = JSON->new;
my $table = Text::ASCIITable->new;
my %tz    = ( time_zone => 'UTC' );
$table->setCols(qw[ ntp rtp ]);
use Devel::Dwarn;
while ( my $line = <STDIN> ) {
    for ( $json->incr_parse($line) ) {
        my $rtcp_epoch =
          $_->{ntp_ts_msw} +
          $ntp_epoch +
          ntp_lsw_to_decimal( $_->{ntp_ts_lsw} );
        my $ntp = DateTime->from_epoch( %tz, epoch => $rtcp_epoch );
        my $rtp =
          DateTime->from_epoch( %tz, epoch => $_->{rtp_ts} + $ntp_epoch );
        $table->addRow( "$ntp", "$rtp" );
    }
}
print $table;
