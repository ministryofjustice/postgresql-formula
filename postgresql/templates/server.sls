include:
  - postgresql.client

kernel.shmmax:
  sysctl.present:
    - value: 800000000
    - require_in:
      - service: postgresql-server

postgresql-9.2:
  pkg:
    - installed

{% set pg_data_dir = '/var/lib/postgresql/9.2/main' %}
{% set pg_config_dir = '/etc/postgresql/9.2/main' %}
{% set pg_pid_file = '/var/run/postgresql/9.2-main.pid' %}

{{pg_config_dir}}/pg_hba.conf:
  file:
    - managed
    - source: salt://postgresql/templates/pg_hba.conf
    - template: jinja
    - mode: 600
    - user: postgres
    - group: postgres
    - require:
      - pkg: postgresql-9.2
    - watch:
      - cmd: postgresql-createcluster

{{pg_config_dir}}/postgresql.conf:
  file:
    - managed
    - source: salt://postgresql/templates/postgresql.conf
    - template: jinja
    - mode: 640
    - user: postgres
    - group: postgres
    - require:
      - pkg: postgresql-9.2
    - watch:
      - cmd: postgresql-createcluster
    - context:
      pg_data_dir: {{pg_data_dir}}
      pg_config_dir: {{pg_config_dir}}
      pg_pid_file: {{pg_pid_file}}

postgresql-createcluster:
  cmd:
    - run
    - user: root
    - group: postgres
    - name: pg_createcluster -e UTF-8 9.2 main
    - unless: "[[ ! -z `pg_lsclusters | grep 9.2 | grep main` ]]"

postgresql-server:
  service:
    - running
    - name: postgresql
    - enable: True
    - reload: True
    - watch:
      - pkg: postgresql-9.2
  require:
    - cmd: postgresql-createcluster

{% if 'postgresql' in pillar %}
{% for dbname, definition in pillar['postgresql'].iteritems() %}

postgres_db_{{dbname}}:
  postgres_database:
    - present
    - name: {{dbname}}
    - encoding: UTF8
    - owner: {{definition['user']}}
    - user: postgres
    - require:
      - postgres_user: postgres_user_{{definition['user']}}


postgres_user_{{definition['user']}}:
  postgres_user:
    - present
    - name: {{definition['user']}}
    - password: {{definition['password']}}
    - encrypted: True
    - user: postgres
    - require:
      - service: postgresql-server
      - file: /etc/profile.d/postgresql.sh
{% if pillar['environment'] == 'staging' %}
    - createdb: True
{% endif %}
{% endfor %}
{% endif %}

{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('postgresql',5432,'tcp') }}
