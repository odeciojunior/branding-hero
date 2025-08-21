#!/bin/bash

# Hive-Mind Initialization Script for Branding-Hero Project
# This script initializes the claude-flow hive-mind configuration

set -e

echo "🧠 Initializing Hive-Mind Configuration for Branding-Hero"

# Configuration paths
CONFIG_DIR="/home/odecio/projects/branding-hero/config"
MEMORY_DIR="/home/odecio/projects/branding-hero/memory"
COORDINATION_DIR="/home/odecio/projects/branding-hero/coordination"

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p "$MEMORY_DIR/agents"
mkdir -p "$MEMORY_DIR/sessions"
mkdir -p "$COORDINATION_DIR/orchestration"
mkdir -p "$COORDINATION_DIR/memory_bank"

# Initialize Claude Flow with hive-mind configuration
echo "🔧 Initializing Claude Flow..."
cd /home/odecio/projects/branding-hero

# Initialize swarm with adaptive hierarchical topology
echo "🌐 Setting up swarm topology..."
npx claude-flow@alpha hooks pre-init --config "$CONFIG_DIR/.hive-mind.json"

# Initialize memory namespaces
echo "💾 Setting up memory namespaces..."
npx claude-flow@alpha memory init --namespace "branding-hero" --config "$CONFIG_DIR/hive-mind-memory.json"
npx claude-flow@alpha memory namespace create --name "branding-hero/project" --ttl "30d"
npx claude-flow@alpha memory namespace create --name "branding-hero/sessions" --ttl "7d"
npx claude-flow@alpha memory namespace create --name "branding-hero/agents" --ttl "24h"
npx claude-flow@alpha memory namespace create --name "branding-hero/shared" --ttl "3d"

# Load neural patterns
echo "🧠 Loading neural patterns..."
npx claude-flow@alpha neural init --config "$CONFIG_DIR/hive-mind-neural.json"
npx claude-flow@alpha neural patterns load --type "branding" --source "$CONFIG_DIR/hive-mind-patterns.json"

# Setup performance monitoring
echo "📊 Configuring performance monitoring..."
npx claude-flow@alpha monitor init --config "$CONFIG_DIR/hive-mind-performance.json"

# Register hooks
echo "🪝 Registering hooks..."
npx claude-flow@alpha hooks register --config "$CONFIG_DIR/hive-mind-hooks.json"

# Create session
echo "🎯 Creating persistent session..."
SESSION_ID="branding-hero-$(date +%Y%m%d-%H%M%S)"
npx claude-flow@alpha session create --id "$SESSION_ID" --persistent true --config "$CONFIG_DIR/.hive-mind.json"

# Store session ID for future use
echo "$SESSION_ID" > "$MEMORY_DIR/current-session-id"

# Validate configuration
echo "✅ Validating configuration..."
npx claude-flow@alpha config validate --config "$CONFIG_DIR/.hive-mind.json"

# Load project context
echo "📚 Loading project context..."
npx claude-flow@alpha memory store \
  --key "branding-hero/project/context" \
  --value "Branding Hero project: Comprehensive brand identity and website development with SPARC methodology" \
  --namespace "branding-hero/project" \
  --ttl "30d"

# Pre-load common patterns
echo "🔄 Pre-loading common patterns..."
npx claude-flow@alpha memory store \
  --key "branding-hero/patterns/workflow" \
  --value "analysis->strategy->design->validation" \
  --namespace "branding-hero/shared" \
  --ttl "7d"

# Initialize agent capabilities
echo "👥 Registering agent capabilities..."
npx claude-flow@alpha agents register --config "$CONFIG_DIR/hive-mind-agents.json"

# Setup auto-spawning rules
echo "🤖 Configuring auto-spawning rules..."
npx claude-flow@alpha agents auto-spawn init --config "$CONFIG_DIR/hive-mind-agents.json"

# Enable real-time coordination
echo "🔗 Enabling real-time coordination..."
npx claude-flow@alpha coordination enable --mode "adaptive-hierarchical" --session "$SESSION_ID"

echo "🎉 Hive-Mind initialization complete!"
echo ""
echo "📋 Summary:"
echo "  - Session ID: $SESSION_ID"
echo "  - Topology: Adaptive Hierarchical"
echo "  - Max Agents: 12"
echo "  - Memory Namespaces: 4"
echo "  - Neural Networks: 4"
echo "  - Hooks: Enabled"
echo "  - Performance Monitoring: Active"
echo ""
echo "🚀 Ready for concurrent agent execution!"
echo "Use: npx claude-flow@alpha status --session $SESSION_ID"