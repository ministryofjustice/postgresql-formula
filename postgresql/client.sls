{% from "postgresql/map.jinja" import postgresql with context %}


include:
  - repos


postgresql-client:
  pkg.installed:
    - name: {{postgresql.pkg.client}}


postgresql-dev:
  pkg.installed:
    - name: {{postgresql.pkg.dev}}
