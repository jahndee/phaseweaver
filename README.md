# PhaseWeaver

An on-chain feature rollout and staging engine on the Stacks blockchain. PhaseWeaver enables contract owners to manage feature lifecycle across four progressive stages (disabled, alpha, beta, production), providing granular control over feature availability with transparent on-chain state management.

## Overview

PhaseWeaver is a Clarity smart contract that implements a sophisticated feature staging system. Features progress through defined rollout stages from alpha testing through production availability, allowing gradual rollout to user segments with complete transparency and immutable records of all staging decisions.

## Features

✓ **4-Tier Staging System** - Progressive rollout: disabled → alpha → beta → production  
✓ **Owner Authorization** - Only authorized owner can manage feature stages  
✓ **Feature Lifecycle** - Move features through complete rollout pipeline  
✓ **Feature Removal** - Delete features when no longer needed  
✓ **Stage Validation** - Prevent invalid stage assignments  
✓ **Status Queries** - Check feature stage and active status efficiently  
✓ **Safe Defaults** - Features default to disabled if not found  

## Rollout Stages

| Stage | Level | Access | Purpose |
|-------|-------|--------|---------|
| 0 | Disabled | None | Feature unavailable to all users |
| 1 | Alpha | Testers | Available to alpha testing audience |
| 2 | Beta | Beta Users | Available to beta testing audience |
| 3 | Production | Everyone | Available to all users |

## Contract Functions

### Authorization Functions

- `set-contract-owner(new-owner)` - Set or transfer contract ownership
  - `new-owner`: Principal address of new owner
  - Can only be called by current owner or if no owner set initially
  - Returns: Success confirmation

### Owner Functions

- `set-feature-stage(feature, stage)` - Set feature to specific stage
  - `feature`: Feature identifier (max 32 ASCII characters)
  - `stage`: Target stage (0=disabled, 1=alpha, 2=beta, 3=production)
  - Creates new feature if doesn't exist, updates if exists
  - Validates stage is within valid range (0-3)
  - Returns: Stage value on success or error code

- `remove-feature(feature)` - Remove feature from system
  - `feature`: Feature identifier to delete
  - Completely removes feature from storage
  - Only callable by contract owner
  - Returns: Success confirmation or error code

### Read-Only Functions

- `feature-stage(feature)` - Get feature's current stage
  - Returns: Stage number (0-3) or STAGE-DISABLED (0) if not found
  - Safe fallback to disabled for missing features

- `feature-active?(feature, min-stage)` - Check if feature meets minimum stage
  - `feature`: Feature identifier
  - `min-stage`: Minimum required stage for activity (0-3)
  - Returns: Boolean true if feature-stage >= min-stage

- `feature-info(feature)` - Query complete feature metadata
  - Returns: Feature data with stage and updated-at timestamp, or error

## State Management

### Configuration Variables

- **contract-owner**: Optional principal tracking current owner (can be set once)

### Storage Maps

- **features**: Stores feature state keyed by feature name
  - `feature`: 32-character ASCII identifier
  - `stage`: Current rollout stage (0-3)
  - `updated-at`: Block height of last update

## Feature Lifecycle
