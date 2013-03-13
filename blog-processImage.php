#!/usr/bin/env php
<?php

$credfile = "credentials-blog.php";

@include($credfile);

if (!(isset($DESTINATION_WEBDIR) && isset($DESTINATION_DIR) && isset($DESTINATION_USER) && isset($DESTINATION_HOST)))
{
    echo "ERROR: the following PHP variables must be defined in $credfile: \n";
    echo " DESTINATION_USER\n DESTINATION_HOST\n DESTINATION_WEBDIR\n DESTINATION_DIR\n";

    die("\n");
}

//check args
if (4 > count($argv))
{
    echo "Usage:\n";
    echo basename($argv[0]) . " <substring_find> <substring_replace> <file1> [[file2] [file3] ...]\n\n";
    echo "Copies all files to:\n";
    echo "    $DESTINATION_USER@$DESTINATION_HOST:$DESTINATION_WEBDIR/$DESTINATION_DIR/\n\n";

    if (1 < count($argv))
    {
        echo "This is what you typed in:\n";

        $first = true;
        foreach ($argv as $k => $v)
        {
            if ($first) 
                $first = false;
            else
                echo "\t$k \t=> '$v'\n";
        }
    }

    die("\n");
}

//set up find, replace... $arr will contain file list
$arr = $argv;
$scriptname = array_shift($arr);
$file_find  = array_shift($arr);
$file_repl  = array_shift($arr);

$all_files = array();
foreach ($arr as $myfile)
{
    $pi = pathinfo($myfile);

    $base = str_replace($file_find, $file_repl, $pi["filename"]);

    //get extension and interlacing
    switch (strtolower($pi["extension"]))
    {
    case "jpeg":
    case "jpg":
        $ext = "jpg";
        $ilace = "JPEG";
        break;
    case "gif":
        $ext = "gif";
        $ilace = "GIF";
        break;
    case "png":
        $ext = "png";
        $ilace = "PNG";
        break;
    default:
        $ext = strtolower($pi["extension"]);
        $ilace = "none";
    }


    $out_thmbsize = "$base.thumb.$ext";
    $out_fullsize = "$base.$ext";

    //resize
    shell_exec("convert \"$myfile\" -thumbnail 240x800\> -interlace $ilace \"$out_thmbsize\"");

    //mogrify
    shell_exec("convert \"$myfile\" -interlace $ilace \"$out_fullsize\"");

    //quote and append
    $all_files[] = "\"$out_thmbsize\"";
    $all_files[] = "\"$out_fullsize\"";

    //output
    $c = $DESTINATION_DIR;
    echo <<<ENDofHTML
<div class="imgbar"><a href="/$c/$out_fullsize"><img src="/$c/$out_thmbsize" /></a></div>

$out_fullsize

<br style="clear:both;" />


ENDofHTML;

}

echo "<!-- end of output -->\n\n";

$all_files_str = implode(" ", $all_files);

//scp
$whattodo = "scp $all_files_str $DESTINATION_USER@$DESTINATION_HOST:$DESTINATION_WEBDIR/$DESTINATION_DIR/";
//echo "DOING THIS:\n\n$whattodo\n\n";
shell_exec($whattodo);
//shell_exec("cp $all_files_str outdir/");

//delete
shell_exec("rm $all_files_str");

?>
