# Apex Query Generator
<a target="_blank" href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

## Overview
This is an freestanding version of the [Nebula framework's](https://github.com/jongpie/NebulaFramework/) query engine - it has been updated to remove any dependencies on the rest of the Nebula framework.

## Features
The overall goal of the project is to generate dynamic SOQL & SOSL queries. Features currently include
* Leverage field-level security to dynamically include fields
* Dynamically include filter conditions (not possible with standard SOQL/SOSL)
* Retain Salesforce's compilation-time errors for invalid fields while still taking advantage of dynamic queries - this helps avoid issues with deleting fields, misspelled field names, etc that can occur when working with strings and dynamic queries
* Support for nearly all SOQL & SOSL features & keywords, including date literals, aggregate results and more
* Easy-to-use query caching