<?php

/**
 * @Author: imxieke
 * @Date:   2021-10-18 01:50:56
 * @Last Modified by:   imxieke
 * @Last Modified time: 2021-10-18 01:55:23
 */

$lists = file_get_contents('pkgs.json');
$lists = json_decode($lists,true);
// print_r($lists);
foreach ($lists['list']['data'] as $key => $val)
{
    // print_r($val);
    echo $val['name'] . ' ';
}