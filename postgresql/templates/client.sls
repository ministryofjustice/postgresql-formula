include:
  - repos.pkgrepo_client


postgresql-client-9.2:
  pkg.installed

libpq-dev:
  pkg.installed

/etc/profile.d/postgresql.sh:
  file:
    - managed
    - source: salt://postgresql/templates/postgresql.sh

