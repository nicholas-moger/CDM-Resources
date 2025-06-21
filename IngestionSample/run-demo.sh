#!/bin/bash

# Rune DSL Demo Build and Run Script
# This script demonstrates the complete workflow for the Rune DSL demo

set -e  # Exit on any error

echo "========================================"
echo "🚀 RUNE DSL DEMO BUILD & RUN SCRIPT"
echo "========================================"

# Step 1: Generate Java code from Rosetta DSL
echo "📋 Step 1: Generating Java code from Rosetta DSL..."
echo "Running: mvn clean compile"
mvn clean compile

if [ $? -eq 0 ]; then
    echo "✅ Code generation successful!"
else
    echo "❌ Code generation failed!"
    exit 1
fi

# Step 2: Compile the demo application
echo ""
echo "📋 Step 2: Compiling demo application..."
echo "Compiling RuneDSLDemo.java with generated classes..."

CLASSPATH="rosetta-source/target/classes:$(find ~/.m2/repository -name '*.jar' -path '*/jackson*' -o -path '*/rosetta*' -o -path '*/guava*' | tr '\n' ':')"

javac -cp "$CLASSPATH" RuneDSLDemo.java

if [ $? -eq 0 ]; then
    echo "✅ Demo compilation successful!"
else
    echo "❌ Demo compilation failed!"
    exit 1
fi

# Step 3: Run the demo
echo ""
echo "📋 Step 3: Running the Rune DSL demo..."
echo "Processing sample XML files and generating JSON output..."
echo ""

java -cp ".:$CLASSPATH" RuneDSLDemo

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Demo execution completed successfully!"
    echo ""
    echo "📁 Generated files:"
    ls -la demo-output/
    echo ""
    echo "🎉 Rune DSL demo completed! Check the demo-output/ directory for JSON files."
else
    echo "❌ Demo execution failed!"
    exit 1
fi
