#!/usr/bin/perl

while ($line = <>){
    if (($line !~  /BEGIN TRANSACTION/) && ($line !~ /COMMIT/) && ($line !~ /sqlite_sequence/) && ($line !~ /CREATE UNIQUE INDEX/)){

        if ($line =~ /CREATE TABLE \"([a-z_]*)\"(.*)/){
                $name = $1;
                $sub = $2;
                $sub =~ s/\"//g; #"
                $line = "DROP TABLE IF EXISTS $name;\nCREATE TABLE IF NOT EXISTS $name$sub\n";
        }
        elsif ($line =~ /INSERT INTO \"([a-z_]*)\"(.*)/){
                $line = "INSERT INTO $1$2\n";
                $line =~ s/\"/\\\"/g; #"
                $line =~ s/\"/\'/g; #"
        }else{
                $line =~ s/\'\'/\\\'/g; #'
        }
        $line =~ s/([^\\'])\'t\'(.)/$1THIS_IS_TRUE$2/g; #'
        $line =~ s/THIS_IS_TRUE/1/g;
        $line =~ s/([^\\'])\'f\'(.)/$1THIS_IS_FALSE$2/g; #'
        $line =~ s/THIS_IS_FALSE/0/g;
        $line =~ s/AUTOINCREMENT/AUTO_INCREMENT/g;
        print $line;
    }
}
