<?php

if (PHP_SAPI !== 'cli' && TYPO3\CMS\Core\Core\Environment::getContext() !== 'Development') {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcuBackend';
} else {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\FileBackend';
}

$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['hash']['backend'] = $crinis_cacheBackendClassName;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['hash']['options'] = [];
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['pages']['backend'] = $crinis_cacheBackendClassName;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['pages']['options'] = [];
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['pagesection']['backend'] = $crinis_cacheBackendClassName;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['pagesection']['options'] = ["defaultLifetime" => 2592000];
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['rootline']['backend'] = $crinis_cacheBackendClassName;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['rootline']['options'] = ["defaultLifetime" => 2592000];
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['imagesizes']['backend'] = $crinis_cacheBackendClassName;
$GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['imagesizes']['options'] = ["defaultLifetime" => 0];
