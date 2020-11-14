<?php

if (!function_exists('crinis_setCacheBackend')) {
    function crinis_setCacheBackend($cacheBackendClassName, $cacheName, $lifetime = NULL)
    {
        $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['backend'] = $cacheBackendClassName;
        if (isset($lifetime))
        {
            $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = array("defaultLifetime" => $lifetime);
        } else {
            $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = array();
        }
    }
}

$crinis_typo3Context = TYPO3\CMS\Core\Core\Environment::getContext();

if (PHP_SAPI !== 'cli' && $crinis_typo3Context !== 'Development') {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcuBackend';
} else {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\FileBackend';
}

crinis_setCacheBackend($crinis_cacheBackendClassName, 'hash');
crinis_setCacheBackend($crinis_cacheBackendClassName, 'pages');
crinis_setCacheBackend($crinis_cacheBackendClassName, 'pagesection', 2592000);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'rootline',2592000);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'imagesizes', 0);
