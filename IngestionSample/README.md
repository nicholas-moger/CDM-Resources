# Rune DSL Comprehensive Demo

This project demonstrates the complete workflow of using **Rune DSL (Rosetta DSL)** for domain modeling, code generation, data ingestion, and business logic execution. It showcases how to create a custom trade domain model and leverage the generated Java code for real-world data processing.

## 🎯 What This Demo Demonstrates

### 1. **Domain-Specific Language (DSL) Modeling**
- Custom trade domain model defined in Rosetta DSL (`.rosetta` files)
- Type-safe business function definitions
- XML ingestion mappings with synonym support

### 2. **Automatic Code Generation**
- Java classes generated from Rosetta definitions
- Type-safe model objects (POJOs)
- Business function interfaces and implementations
- Ingestion framework integration

### 3. **Data Integration & Processing**
- XML-to-Model data transformation
- Business rule validation and calculation
- JSON output projection

### 4. **End-to-End Workflow**
- Maven build process for code generation
- Custom Java integration with generated code
- Sample data processing and output

## 🏗️ Project Structure

```
/coding/CDM/common-domain-model/
├── pom.xml                           # Root Maven configuration
├── RuneDSLDemo.java                  # 🔧 USER-WRITTEN: Main demo application
├── demo-output/                      # Generated JSON outputs
│   ├── sample-trade-buy.json
│   ├── sample-trade-sell.json
│   └── sample-trade-cancelled.json
├── examples/
│   └── src/main/resources/
│       ├── sample-trade-buy.xml     # 🔧 USER-WRITTEN: Sample XML data
│       ├── sample-trade-sell.xml    # 🔧 USER-WRITTEN: Sample XML data
│       └── sample-trade-cancelled.xml # 🔧 USER-WRITTEN: Sample XML data
└── rosetta-source/
    ├── pom.xml                      # Module Maven configuration
    ├── src/main/rosetta/            # 🔧 USER-WRITTEN: Rosetta DSL definitions
    │   ├── annotations.rosetta      # 🔧 USER-WRITTEN: Annotations
    │   ├── basictypes.rosetta       # 🔧 USER-WRITTEN: Basic types
    │   ├── demo-trade-functions.rosetta    # 🔧 USER-WRITTEN: Business functions
    │   └── demo-trade-ingestion.rosetta    # 🔧 USER-WRITTEN: Ingestion mappings
    ├── src/main/java/demo/trade/ingestion/
    │   └── CustomIngestTradeXML.java # 🔧 USER-WRITTEN: Custom ingestion logic
    ├── src/generated/java/           # 🤖 GENERATED: Java classes from Rosetta
    │   └── demo/trade/
    │       ├── model/               # 🤖 GENERATED: Model classes
    │       │   ├── Trade.java
    │       │   ├── TradeRoot.java
    │       │   ├── TradeHeader.java
    │       │   ├── TradeEconomics.java
    │       │   ├── TradeParties.java
    │       │   └── ...
    │       └── functions/functions/ # 🤖 GENERATED: Business functions
    │           ├── CalculateTradeNotional.java
    │           ├── ValidateTrade.java
    │           ├── GetTradeDescription.java
    │           └── IsActiveTrade.java
    └── target/                      # Compiled classes
```

## 📝 Files Written by Users (vs Generated)

### 🔧 **User-Written Files** (Domain experts and developers create these):

1. **Rosetta DSL Files** (`rosetta-source/src/main/rosetta/`):
   - `demo-trade-functions.rosetta` - Business logic definitions
   - `demo-trade-ingestion.rosetta` - Data ingestion and mapping rules
   - `basictypes.rosetta` - Custom types and enums
   - `annotations.rosetta` - Model annotations

2. **Integration Code**:
   - `RuneDSLDemo.java` - Main application integrating with generated code
   - `CustomIngestTradeXML.java` - Custom XML parsing implementation

3. **Sample Data**:
   - `sample-trade-*.xml` - Test data files

### 🤖 **Generated Files** (Rosetta compiler creates these):
- All files in `src/generated/java/` directory
- Model classes (`Trade`, `TradeHeader`, etc.)
- Function implementations (`CalculateTradeNotional`, etc.)
- Builder patterns and validation logic

## 🚀 Build Process

### Step 1: Generate Java Code from Rosetta DSL
```bash
# Navigate to project root
cd /coding/CDM/common-domain-model

# Run Maven build to generate Java code from .rosetta files
mvn clean compile
```

**What happens:**
- Rosetta Maven plugin processes `.rosetta` files
- Generates type-safe Java classes in `src/generated/java/`
- Compiles both generated and custom Java code
- Downloads dependencies (Jackson, Guava, etc.)

### Step 2: Compile and Run the Demo
```bash
# Compile the demo (outside of Maven, as a user integration)
javac -cp "rosetta-source/target/classes:$(find ~/.m2/repository -name '*.jar' -path '*/jackson*' -o -path '*/rosetta*' -o -path '*/guava*' | tr '\n' ':')" RuneDSLDemo.java

# Run the demo
java -cp ".:rosetta-source/target/classes:$(find ~/.m2/repository -name '*.jar' -path '*/jackson*' -o -path '*/rosetta*' -o -path '*/guava*' | tr '\n' ':')" RuneDSLDemo
```

**What happens:**
- Reads sample XML files
- Uses custom ingestion to parse XML into generated model objects
- Applies generated business functions for validation and calculation
- Outputs results as JSON to console and files

## 🔄 Complete Workflow Explained

### 1. **Domain Modeling Phase**
Domain experts define the business model in Rosetta DSL:
```rosetta
// In demo-trade-functions.rosetta
type Trade:
    tradeHeader TradeHeader (1..1)
    tradeEconomics TradeEconomics (1..1)
    parties TradeParties (1..1)

func CalculateTradeNotional:
    inputs: trade Trade (1..1)
    output: notional number (1..1)
```

### 2. **Code Generation Phase**
Maven build generates Java code:
```java
// Generated Trade.java
public interface Trade extends RosettaModelObject {
    TradeHeader getTradeHeader();
    TradeEconomics getTradeEconomics();
    TradeParties getParties();
    // ... builder methods, validation, etc.
}
```

### 3. **Integration Phase**
Developers write integration code:
```java
// User-written RuneDSLDemo.java
CustomIngestTradeXML ingestFunction = new CustomIngestTradeXML();
TradeRoot tradeRoot = ingestFunction.evaluate(xmlContent);

CalculateTradeNotional calculator = new CalculateTradeNotional.CalculateTradeNotionalDefault();
BigDecimal notional = calculator.evaluate(trade);
```

### 4. **Execution Phase**
- XML data is ingested and transformed into typed objects
- Business functions are applied for validation and calculation
- Results are projected as JSON output

## 📊 Sample Output

The demo processes three sample trades and outputs:

1. **Console Output**: Detailed processing information
2. **JSON Files**: Structured data in `demo-output/` directory

Example JSON output:
```json
{
  "trade": {
    "tradeHeader": {
      "tradeId": "TRADE-BUY-001",
      "tradeDate": { "day": 21, "month": 6, "year": 2025 },
      "tradeStatus": "ACTIVE"
    },
    "tradeEconomics": {
      "direction": "BUY",
      "quantity": 1000,
      "price": 105.50,
      "currency": "USD",
      "notional": 105500.00
    },
    "parties": {
      "buyer": "ABC Investment Fund",
      "seller": "XYZ Trading Corp",
      "broker": "Prime Brokerage LLC"
    }
  }
}
```

## 🎯 Key Benefits Demonstrated

### **For Domain Experts:**
- Express business logic in domain-specific language
- No need to write Java code
- Version control and review business rules as code

### **For Developers:**
- Type-safe integration with domain models
- Automatic code generation eliminates manual coding errors
- Clean separation between business logic and technical implementation

### **For Organizations:**
- Regulatory compliance through traceable business rules
- Consistent data transformation across systems
- Rapid prototyping and model evolution

## 🧪 Running the Demo

### Option 1: Quick Start (Recommended)
```bash
# One-command execution
./run-demo.sh
```

### Option 2: Manual Steps
1. **Prerequisites:**
   - Java 21+
   - Maven 3.6+

2. **Step-by-step execution:**
   ```bash
   # Generate code from Rosetta DSL
   mvn clean compile
   
   # Compile demo
   javac -cp "rosetta-source/target/classes:$(find ~/.m2/repository -name '*.jar' -path '*/jackson*' -o -path '*/rosetta*' -o -path '*/guava*' | tr '\n' ':')" RuneDSLDemo.java
   
   # Run demo
   java -cp ".:rosetta-source/target/classes:$(find ~/.m2/repository -name '*.jar' -path '*/jackson*' -o -path '*/rosetta*' -o -path '*/guava*' | tr '\n' ':')" RuneDSLDemo
   ```

3. **Expected Output:**
   - Console logging of processing steps
   - JSON files in `demo-output/` directory
   - Summary of successful workflow execution

## 🔍 Understanding the Architecture

This demo showcases a **model-driven architecture** where:

1. **Business Logic** is defined declaratively in Rosetta DSL
2. **Implementation** is generated automatically
3. **Integration** is done through type-safe APIs
4. **Evolution** happens at the model level, not implementation level

This approach is particularly powerful for:
- Financial services and regulatory compliance
- Data transformation and validation
- Cross-system integration
- Audit trails and business rule governance

---

**This demo proves that Rune DSL enables rapid, type-safe development of complex domain models with automatic code generation, data transformation, and business logic execution.**
