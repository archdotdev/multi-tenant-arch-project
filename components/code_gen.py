import subprocess
import yaml
import argparse

# Create argument parser
parser = argparse.ArgumentParser()

# Add arguments
parser.add_argument("--source_name")
parser.add_argument("--schema_name")
parser.add_argument("--database_name")
parser.add_argument("--write_path")
args = parser.parse_args()

project_name = args.write_path.split("/")[0]
sources_path = f"{args.write_path}/sources.yml"

command = f"""dbt --quiet run-operation generate_source --args '{{"name": "{args.source_name}","schema_name": "{args.schema_name}", "database_name": "{args.database_name}", "table_pattern": "%"}}'"""
output = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=f"{project_name}/")
with open(sources_path, "w") as file:
    file.write(output.stdout)


data = yaml.safe_load(output.stdout)
table_names = [table.get("name") for table in data.get("sources")[0].get("tables")]
for table in table_names:
    command = f"""dbt --quiet run-operation codegen.generate_base_model --args '{{"source_name": "{args.source_name}", "table_name": "{table}", "case_sensitive_cols": "true"}}' | tail -n +3 >> models/staging/stg_{args.source_name}__{table}.sql"""
    output = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=f"{project_name}/")
