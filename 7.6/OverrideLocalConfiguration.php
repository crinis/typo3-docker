<?php

function var_export_short_syntax($expression, $return=false) 
{
    $export = var_export($expression, true);
    $export = preg_replace("/^([ ]*)(.*)/m", '$1$1$2', $export);
    $array = preg_split("/\r\n|\n|\r/", $export);
    $array = preg_replace(["/\s*array\s\($/", "/\)(,)?$/", "/\s=>\s$/"], [null, ']$1', ' => ['], $array);
    $export = join(PHP_EOL, array_filter(["["] + $array));
    if ((bool)$return) {
        return $export;
    } else {
         echo $export;
    }
}

$localConfiguration = include '/var/www/html/typo3conf/LocalConfiguration.php';
$localConfigurationOverrides = yaml_parse_file('/docker/config/local-configuration-overrides.yml');

if ($localConfigurationOverrides && is_array($localConfigurationOverrides)) {
    $overridenLocalConfiguration = array_replace_recursive($localConfiguration, $localConfigurationOverrides);
    if ($overridenLocalConfiguration) {
        file_put_contents(
            '/var/www/html/typo3conf/LocalConfiguration.php', 
            "<?php\nreturn " . var_export_short_syntax($overridenLocalConfiguration, true) . "\n?>"
        );
    }
}
