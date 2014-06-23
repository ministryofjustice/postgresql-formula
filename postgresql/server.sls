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


lc_messages_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options.lc_messages }}


lc_monetary_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options.lc_monetary }}


lc_numeric_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options.lc_numeric }}


lc_time_locale:
  cmd.run:
    - name: locale-gen {{ postgresql.options.lc_time }}


postgresql:
  pkg:
    - installed
    - name: {{ postgresql.pkg.server }}
  service:
    - running
    - enable: true
    - name: {{ postgresql.service }}
    - require:
      - pkg: {{ postgresql.pkg.server }}


pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/{{ postgresql.version }}/main/pg_hba.conf
    - source: salt://postgresql/templates/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: {{ postgresql.pkg.server }}
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
    - require:
      - pkg: {{ postgresql.pkg.server }}
    - watch_in:
      - service: postgresql


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('postgresql',5432,proto='tcp') }}
