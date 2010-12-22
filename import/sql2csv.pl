#!/usr/bin/env perl

# '(.*?)(?<!\\)'

$/="),(";
while(<>){
    s|\),\($||mg; 
    s|\n||mg; 
    s|\);\s*INSERT|\n|mg; 
    s|\);.*$||mg;
    s|^.*VALUES \(||mg; 
    print $_."\n"; 
}
