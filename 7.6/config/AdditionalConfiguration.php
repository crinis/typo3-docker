<?php

function setAPCuCacheBackend($cacheName)
{
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['backend'] = 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcuBackend';
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = [];
}

if (PHP_SAPI !== 'cli') {
    setAPCuCacheBackend('cache_hash');
    setAPCuCacheBackend('cache_imagesizes');
    setAPCuCacheBackend('cache_pages');
    setAPCuCacheBackend('cache_pagesection');
    setAPCuCacheBackend('cache_rootline');
    setAPCuCacheBackend('extbase_datamapfactory_datamap');
    setAPCuCacheBackend('extbase_object');
    setAPCuCacheBackend('extbase_reflection');
    setAPCuCacheBackend('extbase_typo3dbbackend_queries');
    setAPCuCacheBackend('extbase_typo3dbbackend_tablecolumns');
}
