{% from "postgresql/map.jinja" import postgresql with context %}
include:
  - bootstrap

{# ensure that locales are installed on the system #}
{% for lc_name in ['lc_messages', 'lc_monetary', 'lc_numeric', 'lc_time'] %}
{{lc_name}}_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options[lc_name] }}
    - onlyif: locale -a | grep -q {{ postgresql.options[lc_name] }}
    - require_in:
      - cmd: postgresql-initdb
    - watch_in:
      - service: postgresql

{% endfor %}

{# TODO: convert above to following after moving to v2014.1.5
lc_messages_locale:
  locale.present:
    - name: {{ postgresql.options.lc_messages }}
#}


pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/{{ postgresql.version }}/main/pg_hba.conf
    - source: salt://postgresql/templates/pg_hba.conf
    - template: jinja
    - mode: 644
    - makedirs: True
    - watch_in:
      - service: postgresql


postgresql.conf:
  file.managed:
    - name: /etc/postgresql/{{ postgresql.version }}/main/postgresql.conf
    - source: salt://postgresql/templates/postgresql.conf
    - template: jinja
    - mode: 644
    - makedirs: True
    - watch_in:
      - service: postgresql


postgresql-pkg:
  pkg.installed:
    - name: {{ postgresql.pkg.server }}
    - require:
      - file: postgresql.conf
      - file: pg_hba.conf
    - watch_in:
      - service: postgresql


postgresql-data_directory:
  file.directory:
    - name: {{ postgresql.options.data_directory }}
    - user: postgres
    - group: postgres
    - require:
      - pkg: postgresql-pkg


/etc/postgresql/{{postgresql.version}}/conf.d:
  file.directory:
    - mode: 755
    - makedirs: True


postgresql-initdb:
  cmd.run:
    - name: /usr/lib/postgresql/{{ postgresql.version }}/bin/initdb -D {{ postgresql.options.data_directory }}
    - user: postgres
    - onlyif: [ -e {{ postgresql.options.data_directory }}/PG_VERSION ]
    - require:
      - pkg: postgresql-pkg
      - file: pg_hba.conf
      - file: postgresql.conf
      - file: postgresql-data_directory
    - watch_in:
      - service: postgresql


postgresql:
  service.running:
    - enable: True
    - reload: True
    - name: {{ postgresql.service }}
    - require:
      - pkg: postgresql-pkg


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('postgresql',5432,proto='tcp') }}
