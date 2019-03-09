<?php

function setAPCCacheBackend($cacheName) 
{
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['backend'] = 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcBackend';
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = [];
}

if (PHP_SAPI !== 'cli') {
    setAPCCacheBackend('cache_hash');
    setAPCCacheBackend('cache_imagesizes');
    setAPCCacheBackend('cache_pages');
    setAPCCacheBackend('cache_pagesection');
    setAPCCacheBackend('cache_rootline');
    setAPCCacheBackend('extbase_datamapfactory_datamap');
    setAPCCacheBackend('extbase_object');
    setAPCCacheBackend('extbase_reflection');
    setAPCCacheBackend('extbase_typo3dbbackend_queries');
    setAPCCacheBackend('extbase_typo3dbbackend_tablecolumns');
}
