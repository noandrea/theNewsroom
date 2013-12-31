<!DOCTYPE html>
<!-- saved from url=(0037)http://bost.ocks.org/mike/miserables/ -->
<html class="ocks-org do-not-copy"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta charset="utf-8">
<title>Les Misérables Co-occurrence</title>
<style>

@import url('style.css');

.background {
  fill: #eee;
}

line {
  stroke: #fff;
}

text.active {
  fill: red;
}

.rotate {
  -webkit-transform: rotate(-90deg);
  -moz-transform: rotate(-90deg);
  -ms-transform: rotate(-90deg);
  -o-transform: rotate(-90deg);
  transform: rotate(-90deg);

  /* also accepts left, right, top, bottom coordinates; not required, but a good idea for styling */
  -webkit-transform-origin: 50% 50%;
  -moz-transform-origin: 50% 50%;
  -ms-transform-origin: 50% 50%;
  -o-transform-origin: 50% 50%;
  transform-origin: 50% 50%;

  /* Should be unset in IE9+ I think. */
  filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
}

</style>
<script src="d3.v2.min.js"></script>

<style type="text/css"></style></head><body><header>
  <aside>April 10, 2012</aside>
  <a href="http://bost.ocks.org/mike/" rel="author">Mike Bostock</a>
</header>



<div>
<table cellspacing="0" style="font-size:12px">
<?php

$json_data = file_get_contents("table_data.json");
$data = json_decode($json_data);

//die(print_r($data));

foreach($data as $tr){
  ?><tr><?php
  foreach ($tr as $td) {
    if(!is_numeric($td)){
      ?><td  style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
    } else if($td == 0){
      ?><td style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
      $td = "";
    } else if($td == 1){
      ?><td style="background-color:yellow;border-bottom:1px solid #222; white-space:nowrap;"><?php  
    } else if($td > 1){
      ?><td style="background-color:red;border-bottom:1px solid #222; white-space:nowrap;"><?php  
    } else {
      ?><td style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
    }
    
    echo $td;
    ?><td><?php
  }
  ?></tr><?php
}


?>
</table>

</div>

<hr>
<div>
<table cellspacing="0" style="font-size:12px">
<?php

// $json_data = file_get_contents("table_data_art.json");
// $data = json_decode($json_data);

// //die(print_r($data));

// foreach($data as $tr){
//   ?><tr><?php
//   foreach ($tr as $td) {
//     if(!is_numeric($td)){
//       ?><td  style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
//     } else if($td == 0){
//       ?><td style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
//       $td = "";
//     } else if($td == 1){
//       ?><td style="background-color:red;border-bottom:1px solid #222; white-space:nowrap;"><?php  
//     } else if($td > 1){
//       ?><td style="background-color:red;border-bottom:1px solid #222; white-space:nowrap;"><?php  
//     } else {
//       ?><td style="border-bottom:1px solid #222; white-space:nowrap;"><?php  
//     }
    
//     echo $td;
//     ?><td><?php
//   }
//   ?></tr><?php
// }


?>
</table>

</div>

</p><footer>
  <aside>January 12, 2012</aside>
  <a href="http://bost.ocks.org/mike/" rel="author">Mike Bostock</a>
</footer>
<div id="directions_extension" style="display: none;"></div></body></html>