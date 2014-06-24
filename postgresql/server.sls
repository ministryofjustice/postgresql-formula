{% from "postgresql/map.jinja" import postgresql with context %}


{# ensure locales are installed on the system #}


{# availabe since v2014.1.5
lc_messages_locale:
  locale.present:
    - name: {{ postgresql.options.lc_messages }}


lc_monetary_locale:
  locale.present:
    - name: {{ postgresql.options.lc_monetary }}


lc_numeric_locale:
  locale.present:
    - name: {{ postgresql.options.lc_numeric }}


lc_time_locale:
  locale.present:
    - name: {{ postgresql.options.lc_time }}
#}


{% for lc_name in ['lc_messages', 'lc_monetary', 'lc_numeric', 'lc_time'] %}

{{lc_name}}_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options[lc_name] }}
    - unless: locale -a | grep -q {{ postgresql.options[lc_name] }}

{% endfor %}

postgres:
  user.present:
    - system: True
    - groups:
      - ssl-cert
    - home: /var/lib/postgresql


postgresql-data_directory:
  file.directory:
    - name: {{ postgresql.options.data_directory }}
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: True
    - require:
      - user: postgres


pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/{{ postgresql.version }}/main/pg_hba.conf
    - source: salt://postgresql/templates/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - makedirs: True
    - require:
      - user: postgres
    - watch_in:
      - service: postgresql


postgresql.conf:
  file.managed:
    - name: /etc/postgresql/{{ postgresql.version }}/main/postgresql.conf
    - source: salt://postgresql/templates/postgresql.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - makedirs: True
    - require:
      - user: postgres
    - watch_in:
      - service: postgresql

{# manually starting postgres as notify service postgres prevents state from execution #}
postgresql-initdb:
  cmd.run:
    - name: |
        /usr/lib/postgresql/{{ postgresql.version }}/bin/initdb -D {{ postgresql.options.data_directory }}
        /etc/init.d/postgresql restart
    - user: postgres
    - unless: [ -e {{ postgresql.options.data_directory }}/PG_VERSION ]
    - require:
      - pkg: postgresql


postgresql:
  pkg.installed:
    - name: {{ postgresql.pkg.server }}
    - require:
      - user: postgres
      - file: postgresql-data_directory
      - file: postgresql.conf
      - file: pg_hba.conf
  service.running:
    - enable: True
    - name: {{ postgresql.service }}
    - require:
      - user: postgres
      - pkg: {{ postgresql.pkg.server }}


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('postgresql',5432,proto='tcp') }}
