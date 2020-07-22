<?php

function setAPCuCacheBackend($cacheName)
{
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['backend'] = \TYPO3\CMS\Core\Cache\Backend\ApcuBackend::class;
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations'][$cacheName]['options'] = [];
}

$context = TYPO3\CMS\Core\Core\Environment::getContext();

if (PHP_SAPI !== 'cli' && $context !== 'Development') {
    setAPCuCacheBackend('hash');
    setAPCuCacheBackend('imagesizes');
    setAPCuCacheBackend('pages');
    setAPCuCacheBackend('pagesection');
    setAPCuCacheBackend('rootline');
}
