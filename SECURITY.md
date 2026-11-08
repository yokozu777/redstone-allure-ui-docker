# Security

This repository packages updated Allure Docker Service API and UI images. It is not the Allure Framework itself. Report a problem in these Dockerfiles, compose files, or scripts privately to the maintainers. Do not open a public issue that includes exploit steps or live credentials.

Vulnerabilities in Allure or in the upstream Docker service belong with those projects:

- API fork: `allure-api/` (from [fescobar/allure-docker-service](https://github.com/fescobar/allure-docker-service))
- UI fork: `allure-fork/` (from [fescobar/allure-docker-service-ui](https://github.com/fescobar/allure-docker-service-ui))

## What is published

The root `docker-compose.yml` does not set `SECURITY_ENABLED`. The API on port **5050** accepts project creation, result upload, and report generation without a login. The UI on port **5252** is plain HTTP. Both ports are published on all interfaces. Put a reverse proxy with TLS in front of them before this stack is reachable beyond your machine.

`ALLURE_DOCKER_PUBLIC_API_URL` is `http://localhost:5050` because the browser calls the API directly. That name is not a secret.

`projects/` is a runtime volume for Allure results and generated reports. Do not commit it. It can contain test names, screenshots, and request data from the suites you publish.

## Dev compose files

`allure-api/docker-compose-dev.yml` and `allure-fork/docker-compose-dev.yml` are upstream development examples. They enable security with the placeholder accounts `my_username` / `my_password` and `view_user` / `view_pass`. Those values are not production credentials. Do not replace them with real passwords and commit the files. The root compose file is the one this repository runs; the dev files point at sibling directories that are not part of this tree.

## Do not commit

- real `SECURITY_USER`, `SECURITY_PASS`, `SECURITY_VIEWER_USER`, or `SECURITY_VIEWER_PASS` values
- TLS private keys (`*.key`, `*.pem`)
- contents of `projects/`, `allure-results/`, or `allure-reports/`
