# Team Kit

Automation tool for peripheral tasks in AI-driven development

Team Kit is a collection of commands that works with AI editors like Claude to automate everything from requirements definition to specification creation and mockup generation.

## Main Features

### 🤖 Automated Workflows
- Automated generation of requirements definitions
- Creation of user stories
- Extraction of use cases
- Generation of UI definitions
- Creation of screen flow diagrams
- Automated generation of HTML mockups

### 📋 Requirements Consistency Check
- Automated verification of requirements consistency
- Automated reflection of verification items

### 👥 User-Centric Evaluation
- Collection and reflection of user feedback
- Maintenance of consistency between requirements and mockups


## Installation

### Prerequisites
- Claude Code
- bash shell environment

### Installation Steps


```bash
# Install to current directory
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- .
```

```
# Force overwrite (no confirmation)
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- --yes .

# Install to a specific directory
curl -fsSL https://raw.githubusercontent.com/tango238/teamkit/main/install.sh | bash -s -- /path/to/project
```

**Options:**
- `--yes`, `-y`, `--force`, `-f`: Overwrite existing files without confirmation

The installation script copies all command files under the `.claude/commands/teamkit` directory to the specified project directory with the same structure.

## Basic Usage

Team Kit provides a step-by-step specification creation workflow. Each step is available as a slash command `/teamkit:*`.

### 1. Project Initialization

First, create a directory to manage specifications:

```
your-project/
└── specs/
    └── YourFeature/
        └── README.md  # Describe requirements
```

README.md example:

```
# Facility Management

## Background

Management of basic information for facilities, room types, and rooms is essential for facility operations. This information forms the basis for reservation management and pricing, so it is necessary to keep it accurate and up-to-date.

## Objectives

- Centralize the management of basic facility information to enable efficient operation of multiple facilities
- Manage the characteristics of each room type to meet diverse accommodation needs
- Appropriately manage the status of each room to accurately determine availability and cleaning requirements

## Main Actors

- Facility Manager
- Cleaning Staff

## Business Overview

Facility management involves the registration, update, deletion, and retrieval of facilities, room types, and rooms. Facility information includes name, address, check-in/check-out times, etc., while room types include capacity and smoking policy. Each room is linked to a room number and room type, and availability is controlled by its status.

## Requirements

### Facility Manager
Register and update facility information, room types, and room information
```

### 2. Create Feature

Extract requirements from `README.md` and generate feature definitions:

```
/teamkit:create-feature YourFeature
```

**Generated Files:**
- `specs/YourFeature/feature.yml` - Feature definition
- `specs/YourFeature/status.json` - Status management file

### 3. Generate HTML Mockup

Generate interactive HTML mockups from UI definitions:

```
/teamkit:create-mock YourFeature
```

**Generated Files:**
- `specs/YourFeature/index.html` - Mockup index page
- `specs/YourFeature/mock/*.html` - Mockups for each screen
- `specs/YourFeature/mock/screens.yml` - Screen generation status

## Useful Commands

### Check Function

Check specification consistency:

```
/teamkit:check YourFeature
```

The AI checks `feature.yml` and lists issues in `check.md`.

Review the content and mark TODOs with `[o]` if you want to apply them.

You can adjust the application content by changing the Recommended action in the Summary.

To apply the checked items marked with `o`, run `/teamkit:update-feature YourFeature`.


### Feedback Function

Submit feedback on specifications:

```
/teamkit:feedback YourFeature --preview "Please split the address field into details"
```

When you submit feedback, the AI checks the scope of impact and creates details and TODOs in `feedback.md`.

Review the content and mark TODOs with `[o]` if you want to apply them.

If you add the `-p` or `--preview` option, the changes will be immediately reflected in the mockup, allowing you to confirm the feedback content.

You can adjust the feedback application content by changing the Next action in the Summary.

Apply feedback:

```
/teamkit:apply-feedback YourFeature
```

### Update Feature

Regenerate the feature when check.md is updated:

```
/teamkit:update-feature YourFeature
```

### Check Status

Check current step information:

```
/teamkit:get-step-info YourFeature
```


## Directory Structure

After installation, the project will have the following structure:

```
your-project/
├── .claude/
├── .claude/
│   └── commands/
│       └── teamkit/            # Team Kit commands
│           ├── create-feature.md
│           ├── generate-story.md
│           ├── generate-usecase.md
│           ├── generate-ui.md
│           ├── generate-screenflow.md
│           ├── generate-mock.md
│           ├── create-mock.md
│           ├── check.md
│           ├── feedback.md
│           ├── apply-feedback.md
│           ├── update-feature.md
│           ├── get-step-info.md
│           ├── update-status.md
│           ├── generate-log.md
│           └── clean.md
└── specs/
    └── <feature-name>/
        ├── README.md          # Requirements definition
        ├── feature.yml        # Functional requirements definition
        ├── story.yml          # User stories
        ├── usecase.yml        # Use cases
        ├── ui.yml             # UI definition
        ├── screenflow.md      # Screen flow diagram
        ├── status.json        # Status management
        ├── feedback.md        # Feedback
        ├── mock/screens.yml   # Screen generation status
        └── mock/*.html        # Mockups for each screen
```

## Workflow Example

Example of a typical development flow:

```bash
# 1. Describe requirements in README.md
# 2. Start with feature definition
/teamkit:create-feature OrderManagement

# 3. Automatically execute all steps
/teamkit:create-mock OrderManagement

# 4. Check the generated mockup
# Open specs/OrderManagement/index.html in a browser

# 5. Submit feedback if any and check the mockup
/teamkit:feedback OrderManagement -p "Please add an order cancellation function"

# 6. Apply feedback
/teamkit:apply-feedback OrderManagement

# 7. Consistency check
/teamkit:check OrderManagement
```

## Output Language

- **Command Descriptions**: English
- **Generated Specifications**: Japanese
- **Status Messages**: Japanese

This allows the LLM to understand accurately while generating specifications in Japanese.

## License

See the [LICENSE](LICENSE) file for the license of this project.

## Support

If you encounter any issues or have feature requests, please report them in the Issues section on GitHub.
