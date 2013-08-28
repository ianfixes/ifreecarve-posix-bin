#!/usr/bin/php
<?php

	$tsize = 100; //thumbnail size
	
	function noresize($name)
	{
		global $argv;
		$fullpath = $name; #$argv[1] . "/$name";
		echo "<node TEXT=\"&lt;html&gt;&lt;img src=&quot;http://ktz.darktech.org/images/mindmaps/$fullpath&quot;/&gt; \" FOLDED=\"true\">\n</node>\n";

		return;
	}
	
	function thumbit($name, $w, $h)
	{
		global $argv;
		$fullpath = $name; #$argv[1] . "/$name";
		echo "<node TEXT=\"&lt;html&gt;&lt;img src=&quot;http://ktz.darktech.org/images/mindmaps/$fullpath&quot; width=&quot;$w&quot; height=&quot;$h&quot;\" FOLDED=\"true\">\n";
		echo "<node TEXT=\"&lt;html&gt;&lt;img src=&quot;http://ktz.darktech.org/images/mindmaps/$fullpath&quot;\" FOLDED=\"true\">\n</node>\n";
		echo "<node LINK=\"http://ktz.darktech.org/images/mindmaps/$fullpath\" TEXT=\"$name\">\n</node>\n";
		echo "</node>\n";

		return;
	}

	if ($argc < 2)
	{
		#die("usage: " . $argv[0] . " IMAGEPATH IMAGE1 [[IMAGE2] ... ]\n");
		die("usage: " . $argv[0] . " IMAGE1 [[IMAGE2] ... ]\n");
	}

	echo "<map version=\"0.7.1\">\n<node TEXT=\"Ian's image generator\" FOLDED=\"false\">\n<node TEXT=\"New Images\" FOLDED=\"true\">\n";

	for ($i=1; $i<$argc; $i++)
	{
		$myimg = $argv[$i];
		$props = getimagesize($myimg);
	
		$w = $props[0];
		$h = $props[1];
	
		//make groups of 5 if there are more than 5 images
		if ($argc > 6 && (($i-1) % 5 == 0))
			echo "<node TEXT=\"Group " . (intval($i/5) + 1) . "\" FOLDED=\"true\">\n";
	
		if ($w <= $tsize && $h <= $tsize)
		{
			noresize($myimg);	
		} 
		else if ($w < $h)
		{
			$w = intval(($tsize * $w) / $h);
			$h = $tsize;
			thumbit($myimg, $w, $h);	
		}
		else
		{
			$h = intval(($tsize * $h) / $w);
			$w = $tsize;
			thumbit($myimg, $w, $h);
		}
		//close group of 5
		if ($argc > 5 && (($i-1) % 5 == 4))
			echo "</node>\n";
	
	}
	//close unfinisheed gorup of 5
	if ($argc > 5 && (($i-2) % 5 != 4))
		echo "</node>\n";

	echo "</node>\n</node>\n</map>\n";
?>
