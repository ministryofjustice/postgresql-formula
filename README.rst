postgresql.formula
================
Installs selected version of postgresql and initializes the db if required.


requirements
------------
Requires bootstrap-formula >= 1.1.0


usage
-----
usage server::

    include:
      - postgresql


usage client only::

    include:
      - postgresql.client


To configure postgresql.conf update it in pillar: `pillar.options.option_name = option`.
See example below on `shared_buffers`.

You can also add your extra configuration files to: /etc/postgresql/*/conf.d/*.conf.


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
