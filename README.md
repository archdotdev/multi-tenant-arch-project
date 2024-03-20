# Multi Tenant Arch Project

This project serves as an example of how you could set up your Arch project repository to support multi tenant use cases.
This is only a reference implementation.
You can choose to set up your project which ever way you prefer.

Checkout the [Zoom clip walkthrough](https://us06web.zoom.us/clips/share/5f2fHeBb5uDWpK22DHKaJjmpJOLttw2eibiiPnNy7AbbTzlNiYPfNfLOFKF01gjLA3T7y15HpM8HuOWqTrlCyQuc.dY5Ob1HEJRgjIY0Q) of this project.

## Project Structure

This project is set up with a `components/` directory that contains all the shared reusable components.
These transformation components are represented as dbt [packages](https://docs.getdbt.com/docs/build/packages).
In addition to the components directory, each client has their own subdirectory in the `clients/` directory.
Each client implementation choses which shared dbt packages to import in it's `package.yml` using local relative references.
The client subirectories provide a way to add additional client specific models in addition to the shared components.

In the same way that clients stitch together component dbt packages, we can also create new components that build on each other by importing in the same way that clients do.

## Getting Started

### Install dbt

Install dbt into a virtual environment.
Feel free to bump the version to the latest.
See the `dbt References` section below for links to the install docs.

```bash
pyenv local 3.11
python -m venv .venv
. .venv/bin/activate
pip install dbt-postgres==1.7.10
```

### Running

- Retrieve your Arch development dbt environment credentials (reach out via Slack if you need this)
- Populate a `.env` file at the top level directory using the `.env.template` in this repo
- Run `source .env` to add those variables to your session
- Navigate to one of the dbt projects and run the debug command:

```bash
source .env
cd components/component_abc/
dbt debug
```

### Creating a New Client or Component

1. `cd <directory>`
1. `dbt init --skip-profile-setup`
1. Alter the `dbt_project.yml` profile configuration to reference `arch`, the shared profile in the `profiles` directory in this repo.

## Code Gen

Using the [codegen](https://hub.getdbt.com/dbt-labs/codegen/latest/) dbt package we're able to accelerate the process of scaffolding a project.
On top of that codegen package, this repo also includes a python script called `code_gen.py` that helps stitch all the commands together in an opinionated way.
Given the following information the scripts will create your `sources.yml` file based on what is in the database and will create basic staging models for each table.
After running the scripts you can then make your manual modifications needed.

```bash
# Using Salesforce as an example
cd components/salesforce_staging
mkdir models/staging
touch packages.yml
# Add the codegen package, see https://hub.getdbt.com/dbt-labs/codegen/latest/
dbt deps
cd ..
python code_gen.py --source_name=salesforce --schema_name=salesforce_raw_tenant-1 --database_name=app --write_path=salesforce_staging/models/staging
```

Pending and issue with writing sources that need to be case sensitive https://github.com/dbt-labs/dbt-codegen/issues/140

## Advanced Patterns

:warning: WARNING: these patterns are experimental and in development.

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
These patterns can be beneficial to define default logic once to keep it consistent across clients.
If you need to add new new default column or set of rows, you apply them to the base models and all client implementations inherit them.

#### Rows

In `component_abc` theres a model called `inherit_model.sql` that implements base logic but also accepts an optional child model, using jinja conditional logic, if it's available.
In this case it looks for a `inherit_model__child` model and appends it's rows to the model, if it's implemented.
For example in `client_foo` the `inherit_model__child` model is defined which effectively allows the project to inherit the parent logic and append new custom logic.
The result is a table with both the base and client specific rows in it.

#### Columns

A variation of this approach is shown with a Salesforce Contacts example which commonly has custom fields that vary between clients.
In `stg_salesforce__Contact.sql` we include the default fields, then we also optionally (existence check is handled by the custom `macros/models_exists.sql` logic) include any custom fields that are defined in `stg_salesforce__Contact_custom.sql`.
The result is a table that contains the default and custom columns together as a single table.

## dbt References

- https://docs.getdbt.com/docs/core/pip-install
- https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup
- https://docs.getdbt.com/reference/resource-configs/postgres-configs
