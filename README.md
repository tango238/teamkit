# Team Kit

Automation tool for peripheral tasks in AI-driven development

Team Kit is a collection of commands that works with AI editors like Claude to automate everything from requirements definition to specification creation and mockup generation.

## Main Features

### 🤖 Automated Workflows
- Automated generation of requirements definitions
- Extraction of use cases
- Generation of UI definitions
- Creation of screen flow diagrams
- Automated generation of HTML mockups

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
└── .teamkit/
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

### 2. Generate All Specifications and Mockups

Generate all specifications and HTML mockups from the README in one command. Workflow is automatically generated if it doesn't exist yet:

```
/teamkit:generate YourFeature
```

**Generated Files:**
- `.teamkit/YourFeature/workflow.yml` - Workflow definition
- `.teamkit/YourFeature/usecase.yml` - Use cases
- `.teamkit/YourFeature/ui.yml` - UI definition
- `.teamkit/YourFeature/screenflow.md` - Screen flow diagram
- `.teamkit/YourFeature/mock/*.html` - Mockups for each screen

**Options:**
```
/teamkit:generate YourFeature --manual     # Also generate user manual
/teamkit:generate YourFeature --test       # Also generate acceptance tests
/teamkit:generate YourFeature --capture    # Capture mock screenshots and embed in manual
/teamkit:generate YourFeature --all        # Generate manual + acceptance tests + screenshots
```

Additional generated files (with options):
- `.teamkit/YourFeature/manual.md` - User operation manual (`--manual` or `--all`)
- `.teamkit/YourFeature/acceptance-test.md` - Acceptance test cases (`--test` or `--all`)
- `.teamkit/YourFeature/mock/screenshots/*.png` - Mock screen screenshots (`--capture` or `--all`)

### 3. Regenerate Mockups Only

If you already have `ui.yml` and want to regenerate mockups:

```
/teamkit:create-mock YourFeature
```

## Useful Commands

### Generate with Options

Generate manual and acceptance test items along with the standard pipeline:

```
/teamkit:generate YourFeature --all
```

### Generate Manual with Screenshots

Generate user manual with mock screen screenshots embedded:

```
/teamkit:generate-manual YourFeature --capture
```

Or as part of the full pipeline:

```
/teamkit:generate YourFeature --manual --capture
```

When `--capture` is specified, screenshots of each mock HTML screen are taken using Playwright and embedded in the manual with Marp-compatible image syntax (`![screen w:560](path)`). The screenshots are saved to `mock/screenshots/`.

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
│   └── commands/
│       └── teamkit/            # Team Kit commands
│           ├── generate-workflow.md
│           ├── generate-usecase.md
│           ├── generate-ui.md
│           ├── generate-screenflow.md
│           ├── generate-mock.md
│           ├── generate-manual.md
│           ├── generate-acceptance-test.md
│           ├── generate.md
│           ├── create-mock.md
│           ├── feedback.md
│           ├── apply-feedback.md
│           ├── get-step-info.md
│           └── update-status.md
└── .teamkit/
    └── <feature-name>/
        ├── README.md          # Requirements definition
        ├── workflow.yml       # Workflow definition
        ├── usecase.yml        # Use cases
        ├── ui.yml             # UI definition
        ├── screenflow.md      # Screen flow diagram
        ├── status.json        # Status management
        ├── feedback.md        # Feedback
        ├── manual.md          # User operation manual (optional)
        ├── acceptance-test.md # Acceptance test cases (optional)
        ├── mock/screens.yml   # Screen generation status
        ├── mock/*.html        # Mockups for each screen
        └── mock/screenshots/  # Mock screen screenshots (optional)
```

## Workflow Example

Example of a typical development flow:

```bash
# 1. Describe requirements in README.md
# 2. Generate all specifications and mockups
/teamkit:generate OrderManagement

# 3. Or generate with manual and acceptance tests
/teamkit:generate OrderManagement --all

# 4. Check the generated mockup
# Open .teamkit/OrderManagement/index.html in a browser

# 5. Submit feedback if any and check the mockup
/teamkit:feedback OrderManagement -p "Please add an order cancellation function"

# 6. Apply feedback
/teamkit:apply-feedback OrderManagement

# 7. Regenerate mockups only (after manual ui.yml edits)
/teamkit:create-mock OrderManagement

# 8. Generate manual with screenshots from mockups
/teamkit:generate-manual OrderManagement --capture
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
