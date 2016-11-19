  sub d6
  {
      return sub { return 1 + int( rand 6 ); };
  }

  sub counter_by
  {
     my ($inc) = @_;
     $inc ||= 1;
     my $count = 0;
     return sub { return $count += $inc; }
  }
