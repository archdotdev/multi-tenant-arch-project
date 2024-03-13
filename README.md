# sample-product


### Project Structure

The project is set up with a `components/` directory that contains all the shared reusable components.
Each client has their own subdirectory in the `clients/` directory that stitches together the shared dbt packages using `package.yml` with local relative references along with additional client specific models.
In the same way that clients stitch together component packages, we can also build additional shared components that bring multiple other components together into a larger component.

### Install dbt

pyenv local 3.11
python -m venv .venv
. .venv/bin/activate
pip install dbt-postgres protobuf==4.25.3

### Running

- If your Arch database instance doesn't have a dbt environment (i.e. `dbt` database, `data` schema, `data_prod` user) set up then run the permission_script.sql
- Populate a .env file using the .env.template
- Run `source .env`
- Navigate to one of the dbt projects and run it
  - `cd clients/client_foo/transforms/client_foo`
  - `dbt run`
  - The result is both client specific models along with the dependecy package models

### Creating a New Client or Component

1. `cd <directory>`
1. `dbt init --skip-profile-setup`
1. Make a copy of profile.yml in a new `profiles` directory in the new project

### dbt References
https://docs.getdbt.com/docs/core/pip-install
https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup
https://docs.getdbt.com/reference/resource-configs/postgres-configs
