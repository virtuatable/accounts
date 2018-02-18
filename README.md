# Accounts service

## Install

### Needed environment variables

#### MongoDB URL

__Name :__ `MONGODB_URL`  
__Type :__ String
__Meaning :__ The URL of the MongoDB database linked to this instance of the service.

#### Service URL

__Name :__ `SERVICE_URL`
__Type :__ String
__Meaning :__ The URL to reach the current service, MUST end with a final slash (/) character.

### Install gems

Run the following commands :

```bash
cd <install_folder>
gem install --no-ri --no-rdoc bundler
bundle
```

### Run the server

To run the development server, use the command : `rackup`

### Run tests suite

To run the test suite, use the command : `rspec`

### Number of existing tests

__Date :__ 18/02/2018 17:21
__Count :__ 52 tests

## How to use

For details about the usage of the service, see the [associated wiki](https://github.com/jdr-tools/accounts/wiki)