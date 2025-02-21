# Gitlab Activity

This project is a Ruby application that provides a user interface for viewing GitLab merge requests and issues.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Features](#features)
- [Screenshots](#screenshots)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Prerequisites

- Ruby (version 3.3 or later)
- Bundler
- GitLab account with personal access token

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/8bitbytes/gitlab-activity.git
   cd gitlab-activity
   ```

2. Install the required gems:
   ```sh
   bundle install
   ```

## Configuration

1. In the settings tab add your GitLab username, personal access token and choose a number of minutes to wait before checking Gitlab for update

## Usage

1. Run the application:
   ```sh
   ruby main.rb
   ```

2. The application will open a user interface with the following tabs:
   - **MRs authored by me**: Displays a list of merge requests authored by the user.
   - **MRs assigned to me**: Displays a list of merge requests assigned to the user.
   - **Issues assigned to me**: Displays a list of issues assigned to the user.
   - **Issues authored by me**: Displays a list of issues authored by the user.
   - **Settings**: Allows the user to configure GitLab credentials and check intervals.

## Features
- View merge requests authored by the user
- View merge requests assigned to the user
- View issues assigned to the user
- View issues authored by the user
- Configure GitLab credentials and check intervals


## FAQ
**Q1: How do I configure the application?**

**A1: Update the values in the settings tab.**

## Troubleshooting
- **Issue**: Application does not start.
  
- **Solution**: Ensure all prerequisites are installed and the configuration file is correctly set up.
- **Enable Logging**: To enable logging, set the `OUTPUT_LOG` environment variable to `TRUE`.

## Development

To contribute to this project, follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with descriptive messages.
4. Push your changes to your fork.
5. Create a pull request to the main repository.

## What does everything do?
**Components**:
   These are custom controls that can be used across many layouts

**Controls**:
   These define the UI Layout of components

**Data Structures**:
Implementations of common data structures

**Extensions**:
Methods to extend the functionality of existing classes

**Models**:
These are the data models that are used to describe the data used by the application

**Presenters**:
There are classes that are used to control the behavior of the UI controls

**Services**:
These are classes that are used to interact with external services as well as manage common functionality in UI controls


## Acknowledgements
- [Built using Glimmer](https://github.com/AndyObtiva/glimmer) - Glimmer is a simple to use dependency free framework for developing Ruby applications. 

## License

This project is licensed under the MIT License. See the [`LICENSE`](LICENSE.md) file for details.
