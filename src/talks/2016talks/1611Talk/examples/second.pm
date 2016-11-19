sub second (&@)
{
    my $pred = shift;
    my $matches = 0;
    foreach (@_)
    {
        if($pred->())
        {
            return $_ if $matches;
            ++$matches;
        }
    }
    return;
}

