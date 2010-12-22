#!/usr/bin/env perl

while(<>) {
    if(m/^(\d+,1?0,'.*?(?<!\\)')/) {
	print $1."\n";
    }
}
