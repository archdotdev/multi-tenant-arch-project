-- This macro checks if a model exists in a list of nodes
{% macro model_exists(child_model_name, nodes) %}
    {%- set matched_nodes = [] -%}
    {%- for node in nodes.values() | selectattr("name", "equalto", child_model_name) -%}
        {%- do matched_nodes.append(node) -%}
    {%- endfor -%}
    {{ return(matched_nodes|length > 0) }}
{% endmacro %}