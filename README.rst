=======
postgresql
=======

Formulas to set up and configure the postgresql server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``init``
----------

Install postgresql from the system package manager and start the service.
This has been tested only on Ubuntu 12.04.

Example usage::

    include:
      - postgresql
