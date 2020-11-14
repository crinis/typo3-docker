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

$crinis_typo3Context = TYPO3\CMS\Core\Utility\GeneralUtility::getApplicationContext();

if (PHP_SAPI !== 'cli' && $crinis_typo3Context !== 'Development') {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcBackend';
} else {
    $crinis_cacheBackendClassName = 'TYPO3\\CMS\\Core\\Cache\\Backend\\FileBackend';
}

crinis_setCacheBackend($crinis_cacheBackendClassName, 'cache_hash');
crinis_setCacheBackend($crinis_cacheBackendClassName, 'cache_pages');
crinis_setCacheBackend($crinis_cacheBackendClassName, 'extbase_datamapfactory_datamap');
crinis_setCacheBackend($crinis_cacheBackendClassName, 'cache_pagesection', 2592000);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'cache_rootline',2592000);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'cache_imagesizes', 0);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'extbase_object', 0);
crinis_setCacheBackend($crinis_cacheBackendClassName, 'extbase_reflection', 0);
