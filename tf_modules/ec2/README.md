# Usage of PostgreSQL

step1: Switch to the postgres User

sudo su - postgres

step2: Connect to the PostgreSQL DB

psql

Step 3: Create a DB and User

Inside psql, you can create a DB and user:

CREATE DATABASE mydb;
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;

Step 4: Enable Remote Connections (Optional)

If you want to connect from outside the EC2:

Edit postgresql.conf:

sudo vi /var/lib/pgsql/data/postgresql.conf
Change:
# listen_addresses = 'localhost'
To:
listen_addresses = '*'

Edit pg_hba.conf:

sudo vi /var/lib/pgsql/data/pg_hba.conf
host    all             all             0.0.0.0/0               md5

Restart PostgreSQL:
sudo systemctl restart postgresql

Step 5: Connect Remotely (e.g., with psql CLI or DBeaver)

psql -h 54.210.123.45 -U myuser -d mydb -W

let see
