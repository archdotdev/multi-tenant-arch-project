# sample-product


## Project Structure

The project is set up with a `components/` directory that contains all the shared reusable components.
Each client has their own subdirectory in the `clients/` directory that stitches together the shared dbt packages using `package.yml` with local relative references along with additional client specific models.
In the same way that clients stitch together component packages, we can also build additional shared components that bring multiple other components together into a larger component.

## Install dbt

pyenv local 3.11
python -m venv .venv
. .venv/bin/activate
pip install dbt-postgres protobuf==4.25.3

## Running

- If your Arch database instance doesn't have a dbt environment (i.e. `dbt` database, `data` schema, `data_prod` user) set up then run the permission_script.sql
- Populate a .env file using the .env.template
- Run `source .env`
- Navigate to one of the dbt projects and run it
  - `cd clients/client_foo/transforms/client_foo`
  - `dbt run`
  - The result is both client specific models along with the dependecy package models

## Patterns

This project implements examples of a few patterns that could be helpful when developing a dbt project in a multi tenant way.

It's common to have a component dbt package that implements a generic set of models for transforming a certain dataset.
In this project we use dbt packages to implement generic transformation component wgucg allows common code to be reused.
Although, sometimes theres a need to modify the generic components slightly to include some client specific logic.
Here are some tools to do that.

### Overriding Component Models

The override pattern allows you to fully override logic from the base package.
For example the `client_foo` project imports the `component_abc` package which contains a model called `override_model.sql` but choses to completely override the logic with a custom implementation.
The way it does this is by setting `+enabled: false` in the `client_foo` `dbt_project.yml` file then creates its own `override_model.sql` with custom logic.
The result is a table with only the client override records in it.

Something to consider when using this pattern is if the base `component_abc` package references this model by name in downstream models then the schema of the override model likely needs to be exactly the same as the original model.
This can be enforced using [schema.yml](https://docs.getdbt.com/reference/resource-configs/schema) definitions including tests or using [model contracts](https://docs.getdbt.com/docs/collaborate/govern/model-contracts).

If you're sure that the package models arent referenced and need to alter the schema in the overriden model you can use the recommendation from [this dbt issue comment](https://github.com/dbt-labs/dbt-core/issues/9762#issuecomment-1997744765) to create a new model like `new_override_model.sql` and alias it as `override_model`.
See https://github.com/dbt-labs/dbt-core/issues/9762.

### Inheriting and Extending Component Models

Another common pattern in software engineering is inheriting from a base class to extend the existing logic, we can acheive something similar in dbt using the pattern shown in this project.
In `component_abc` theres a model called `inherit_model.sql` that implements base logic but also accepts an optional child model, using jinja conditional logic, if it's available.
In this case it looks for a `inherit_model__child` model and appends it's contents if it's implemented.
For example in `client_foo` the `inherit_model__child` model is defined which effectively allows the project to inherit the parent logic and append new custom logic.
The result is a table with both the base and client specific records in it.


## Creating a New Client or Component

1. `cd <directory>`
1. `dbt init --skip-profile-setup`
1. Make a copy of profile.yml in a new `profiles` directory in the new project

## dbt References
https://docs.getdbt.com/docs/core/pip-install
https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup
https://docs.getdbt.com/reference/resource-configs/postgres-configs
