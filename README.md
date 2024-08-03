# dbt_template

Free template for setting up dbt for the first time

Video Guide:

## Snowflake Setup

```sql
/**
    Account setup
*/
use role securityadmin;
create role if not exists dbt;

use role sysadmin;
create warehouse if not exists dbt;
alter warehouse dbt set
    warehouse_size = xsmall
    auto_resume = true
    auto_suspend = 60;

grant usage on warehouse dbt to role dbt;
    
create database if not exists datawarehouse;
grant usage, create schema on database datawarehouse to role dbt;


/**
    Developer setup

    Starlight Insights recommends using a separate 
    Snowflake user for managing dbt locally, 
    as dbt requires unencrypted access to 
    Snowflake credentials.
*/
set developer_username = 'martin';
set password = ''; -- Use a password generator, like: avast.com/random-password-generator
set email = 'martin@starlightinsights.com';

use role securityadmin;
create user if not exists identifier($developer_username)
    password = $password
    email = $email
    must_change_password = true;

-- Here you can grant the appropriate roles to the developer.

set dbt_developer_username = concat('dbt_', $developer_username);
create user if not exists identifier($dbt_developer_username)
    password = $password
    email = $email
    must_change_password = false;

grant role dbt to user identifier($dbt_developer_username);

/**
    Deployer setup
*/
set github_action_password = '';

use role securityadmin;

create role if not exists github_action;

create user if not exists github_action
    password = $github_action_password
    must_change_password = false;
    
use role sysadmin;
create warehouse if not exists github_action;
alter warehouse github_action set
    warehouse_size = xsmall
    auto_resume = true
    auto_suspend = 60;

grant usage on warehouse github_action to role github_action;
grant usage, create schema on database datawarehouse to role github_action;

use role securityadmin;
set user_name = current_user();
grant role github_action to user identifier($user_name);

use role github_action;
create schema if not exists datawarehouse.datawarehouse;

```

_**if you need to drop everything**_
```sql
/**
    Drop everything
*/
use role accountadmin;
drop warehouse dbt;
drop warehouse github_action;
drop database datawarehouse;
drop role dbt;
drop role github_action;
drop user github_action;
drop user identifier($developer_username);
drop user identifier($dbt_developer_username);
```

## Codespace Secrets
