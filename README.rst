postgresql.formula
================
Installs selected version of postgresql.


usage
-----
usage server::

    include:
      - postgresql


usage client only::

    include:
      - postgresql.client


To configure postgresql.conf fill in the pillar.options.option_name = option value.
See example below on `shared_buffers`.

Don't forget that if you need way more specific reconfiguration of package, than you can overwrite templates
in your main `file_roots` folder.

See salt docs `file_roots <http://docs.saltstack.com/en/latest/ref/file_server/file_roots.html>`_


pillar
------
example::

    postgresql:
        version: 9.3
        pkg
           server: postgresql-9.3
           dev: postgresql-server-dev-9.3
           client: postgresql-client-9.3
        options:
           shared_buffers: 128MB
        service: postgresql
