We want to extend our system to include a component for data collection for the pinniped monitoring program.

One such software we have looked at is ODK. [ODK - Open Data Kit](https://getodk.org/)

The deliverables for this option would include;

- The docker compose YAML file to integrate the ODK system with our existing system, currently orchestrated using docker compose. [ODK Docker Compose](https://docs.getodk.org/central-install/#self-hosting)

- XLSForms for the pinniped data collection, and potentially others (microtrolling, field tagging, etc). [XLSForms](https://docs.getodk.org/xlsform/)

- Code to integrate data collected and stored in ODK Central into our Postgres Data Warehouse. I have considered using Foreign Data Wrappers for this purpose. [Foreign Data Wrappers](https://www.postgresql.org/docs/current/postgres-fdw.html)

You can find ODK documentation here: [ODK Docs](https://docs.getodk.org/getting-started/)

Please view the document "Lower_River_Pinniped_Monitoring_Study_Design_2024" in the documents section for further description of the app.
