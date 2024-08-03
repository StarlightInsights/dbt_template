# dbt_template

Free template for setting up dbt for the first time: https://github.com/StarlightInsights/dbt_template

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


/**
    Generate demo data
*/

use role sysadmin;
create database data_loader;
create schema data_loader.accounting_system;

grant usage on database data_loader to role dbt;
grant usage on schema data_loader.accounting_system to role dbt;

use role accountadmin;
grant select on future tables in schema data_loader.accounting_system to role dbt;

use role sysadmin;

set seed_value = 47;

create or replace table data_loader.accounting_system.stores (
    id int autoincrement,
    store_name string,
    location string
);

insert into data_loader.accounting_system.stores (store_name, location)
select
    'store ' || seq4() as store_name,
    coalesce(array_construct('London', 'Paris', 'Berlin', 'Madrid', 'Rome', 'Vienna', 'Amsterdam', 'Brussels', 'Copenhagen', 'Dublin')[uniform(1, 10, random($seed_value))], 'London') as location
from table(generator(rowcount => 10));

create or replace table customers (
    id int autoincrement,
    customer_name string,
    email string,
    city string
);

insert into data_loader.accounting_system.customers (customer_name, email, city)
select
    coalesce(concat(
        chr(uniform(65, 90, random($seed_value))),
        lower(randstr(5, random($seed_value))),
        ' ',
        chr(uniform(65, 90, random($seed_value))),
        lower(randstr(7, random($seed_value)))
    ), 'Default Name') as customer_name,
    coalesce(lower(concat(randstr(8, random($seed_value)), '@example.com')), 'default@example.com') as email,
    coalesce(array_construct('London', 'Paris', 'Berlin', 'Madrid', 'Rome', 'Vienna', 'Amsterdam', 'Brussels', 'Copenhagen', 'Dublin', 'Stockholm', 'Helsinki', 'Oslo', 'Lisbon', 'Athens')[uniform(1, 15, random($seed_value))], 'London') as city
from table(generator(rowcount => 500));

create or replace table data_loader.accounting_system.sales (
    id int autoincrement,
    customer_id int,
    store_id int,
    quantity int,
    amount decimal(38, 4)
);

insert into data_loader.accounting_system.sales (customer_id, store_id, quantity, amount)
select
    coalesce(uniform(1, 500, random($seed_value)), 1) as customer_id,
    coalesce(uniform(1, 10, random($seed_value)), 1) as store_id,
    coalesce(uniform(1, 10, random($seed_value)), 1) as quantity,
    coalesce(round(uniform(10, 1000, random($seed_value)), 2), 10.00) as amount
from table(generator(rowcount => 100000000));
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
drop database data_loader;
drop role dbt;
drop role github_action;
drop user github_action;
drop user identifier($developer_username);
drop user identifier($dbt_developer_username);
```

## Codespace Secrets
