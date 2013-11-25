deploy-scripts
==============

Some deployment scripts

Instructions
------------
Clone with --recurse option

    git clone --recurse git@github.com:NITEMAN/deploy-scripts.git

or initialite submodules after clonning

    git clone git@github.com:NITEMAN/deploy-scripts.git
    cd deploy-scripts
    git submodule update --init --recursive

TODO
----

* FIX APACHE2CTL
* Add Varnish support
* Add CONF_OVERWRITE support for non drupal scripts
* Add symlink support for non drupal deployments
* Add registry_rebuild as submodule (https://drupal.org/project/registry_rebuild) (drush --include=pathamiregistryrebuid rr)
