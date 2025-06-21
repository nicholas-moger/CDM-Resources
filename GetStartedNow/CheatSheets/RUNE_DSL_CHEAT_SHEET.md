# Rune DSL Cheat Sheet
*A Comprehensive Guide to Rune Domain Specific Language*

---

## 🌟 What is Rune DSL?

Rune DSL (Domain Specific Language) is a specialized language for defining business rules, data structures, and calculations in financial and regulatory contexts. Think of it as a way to write business logic that both humans and computers can understand clearly.

---

## 📚 Core Building Blocks

### 1. **Type** - Data Containers
*Think of these as forms or templates that define what information we need to collect*

```rosetta
type Person:
    // Like fields on a form
    firstName string (1..1)     // Required: exactly one first name
    lastName string (1..1)      // Required: exactly one last name
    age int (0..1)             // Optional: zero or one age
    addresses Address (0..*)    // Optional: zero or many addresses
    
    // Business rule: every person must have a name
    condition: firstName exists and lastName exists
```

**Real-world analogy**: Like a customer registration form - it defines what information is required (name) and what's optional (age, multiple addresses).

### 2. **Enum** - Fixed Choices
*Like multiple choice questions with predefined answers*

```rosetta
enum Currency:
    USD    // US Dollar
    EUR    // Euro
    GBP    // British Pound
    JPY    // Japanese Yen
    
enum RiskLevel:
    LOW
    MEDIUM
    HIGH
    CRITICAL
```

**Real-world analogy**: Like a dropdown menu in a form - you can only pick from the available options (you can't invent a new currency).

### 3. **Synonym** - Alternative Names
*Different ways to refer to the same thing, like nicknames*

```rosetta
type Contract:
    contractId string (1..1)
        synonym "Agreement ID", "Deal Reference"
    
    notionalAmount number (1..1)
        synonym "Principal Amount", "Face Value"
```

**Real-world analogy**: Like how "car" and "automobile" mean the same thing - different departments might use different terms for the same concept.

### 4. **Functions** - Calculations and Logic
*Like Excel formulas that perform calculations or make decisions*

```rosetta
// Simple calculation function
func calculateInterest(principal number, rate number, years number) -> number:
    return principal * rate * years

// Decision-making function  
func determineRiskLevel(creditScore int) -> RiskLevel:
    if creditScore >= 750
    then return RiskLevel -> HIGH
    else if creditScore >= 650  
    then return RiskLevel -> MEDIUM
    else return RiskLevel -> LOW

// Validation function
func isValidEmail(email string) -> boolean:
    return email contains "@" and email contains "."
```

**Real-world analogy**: Like recipes or instruction manuals - they take ingredients (inputs) and tell you exactly how to create the result (outputs).

---

## 🏗️ Advanced Concepts

### 5. **Meta** - Information About Information
*Like labels or tags that provide extra context*

```rosetta
type BankAccount:
    accountNumber string (1..1)
        [metadata "This is the unique identifier for the account"]
        
    balance number (1..1)
        [metadata "Current account balance in the account's base currency"]
        
    // Meta information for the entire type
    [metadata "Represents a standard bank account with balance tracking"]
```

**Real-world analogy**: Like the nutrition label on food packaging - it doesn't change what the food is, but gives you important information about it.

### 6. **Conditions** - Business Rules
*Like quality control checks that ensure everything is correct*

```rosetta
type LoanApplication:
    applicantAge int (1..1)
    loanAmount number (1..1)
    creditScore int (1..1)
    
    // Business rules that must be true
    condition "Minimum Age": applicantAge >= 18
    condition "Valid Credit Score": creditScore >= 300 and creditScore <= 850
    condition "Reasonable Loan Amount": loanAmount > 0 and loanAmount <= 1000000
```

**Real-world analogy**: Like the rules for getting a driver's license - you must be a certain age, pass tests, etc.

---

## 💼 Real-World Examples

### Banking Example

```rosetta
// Account types
enum AccountType:
    CHECKING
    SAVINGS  
    INVESTMENT
    CREDIT

// Customer information
type Customer:
    customerId string (1..1)
        synonym "Client ID", "Customer Reference"
    fullName string (1..1)
    dateOfBirth date (1..1)
    accounts BankAccount (1..*)
    
    condition "Adult Customer": 
        dateOfBirth < today() - 18 years

// Bank account details
type BankAccount:
    accountNumber string (1..1)
    accountType AccountType (1..1)
    balance number (1..1)
        synonym "Current Balance", "Available Funds"
    currency Currency (1..1)
    
    condition "Positive Balance for Savings": 
        if accountType = AccountType -> SAVINGS
        then balance >= 0

// Calculate interest earned
func calculateMonthlyInterest(account BankAccount, rate number) -> number:
    if account -> accountType = AccountType -> SAVINGS
    then return account -> balance * rate / 12
    else return 0
```

### Insurance Example

```rosetta
enum PolicyType:
    LIFE
    AUTO
    HOME
    HEALTH

enum ClaimStatus:
    SUBMITTED
    UNDER_REVIEW
    APPROVED
    DENIED
    PAID

type InsurancePolicy:
    policyNumber string (1..1)
        synonym "Policy ID", "Contract Number"
    policyType PolicyType (1..1)
    premiumAmount number (1..1)
    coverageAmount number (1..1)
        synonym "Insured Amount", "Coverage Limit"
    
    condition "Coverage exceeds premium": 
        coverageAmount > premiumAmount

type Claim:
    claimNumber string (1..1)
    claimAmount number (1..1)
    status ClaimStatus (1..1)
    policy InsurancePolicy (1..1)
    
    condition "Claim within coverage": 
        claimAmount <= policy -> coverageAmount

// Determine if claim should be auto-approved
func shouldAutoApprove(claim Claim) -> boolean:
    return claim -> claimAmount < 1000 
        and claim -> policy -> policyType <> PolicyType -> LIFE
```

---

## 🔢 Common Patterns

### Data Validation Patterns

```rosetta
type EmailAddress:
    email string (1..1)
    condition "Valid Email Format": 
        email contains "@" and email contains "."

type PhoneNumber:
    number string (1..1)
    countryCode string (1..1)
    condition "US Phone Number": 
        if countryCode = "US" 
        then number matches "^[0-9]{10}$"  // 10 digits exactly
```

### Calculation Patterns

```rosetta
// Percentage calculations
func calculatePercentage(part number, whole number) -> number:
    return (part / whole) * 100

// Tax calculations  
func calculateTax(amount number, taxRate number) -> number:
    return amount * taxRate

// Age calculation
func calculateAge(birthDate date) -> int:
    return years between birthDate and today()
```

### List Operations

```rosetta
// Working with multiple items
func getTotalBalance(accounts BankAccount multiple) -> number:
    return sum(accounts -> balance)

func getHighValueAccounts(accounts BankAccount multiple) -> BankAccount multiple:
    return accounts filter balance > 10000

func hasAnyOverdraft(accounts BankAccount multiple) -> boolean:
    return accounts exists [balance < 0]
```

---

## 📝 Key Terminology

| Term | Simple Explanation | Example |
|------|-------------------|---------|
| **Type** | A template for data, like a form | `Customer`, `BankAccount` |
| **Enum** | A list of allowed choices | `Currency`, `RiskLevel` |
| **Synonym** | Another name for the same thing | "Customer ID" = "Client Reference" |
| **Function** | A calculation or decision rule | `calculateInterest()` |
| **Condition** | A business rule that must be true | "Age must be 18 or older" |
| **Meta** | Extra information about data | Documentation, descriptions |
| **Cardinality** | How many items are allowed | `(1..1)` = exactly one, `(0..*)` = zero or more |
| **Attribute** | A piece of information in a type | `firstName`, `balance` |

---

## 🎯 Quick Reference

### Cardinality (How Many?)
- `(1..1)` - Required, exactly one
- `(0..1)` - Optional, at most one  
- `(1..*)` - Required, one or more
- `(0..*)` - Optional, zero or more
- `(2..5)` - Between 2 and 5 items

### Common Operators
- `=` - equals
- `<>` - not equals  
- `>`, `<`, `>=`, `<=` - comparisons
- `and`, `or` - logical operations
- `exists` - check if something has a value
- `contains` - check if text contains something
- `filter` - select items that match criteria
- `sum` - add up numbers
- `count` - count how many items

### Basic Data Types
- `string` - Text (like names, addresses)
- `number` - Numbers with decimals
- `int` - Whole numbers only
- `boolean` - True or false
- `date` - Calendar dates
- `time` - Clock times

---

## 💡 Best Practices

1. **Use Clear Names**: `customerAge` instead of `age`
2. **Add Conditions**: Always validate your data
3. **Document with Meta**: Explain what things mean
4. **Use Synonyms**: Different teams may use different terms
5. **Group Related Data**: Put related information in the same type
6. **Make Functions Simple**: Each function should do one thing well

---

*This cheat sheet covers the essential concepts of Rune DSL. For more advanced features and detailed syntax, refer to the official Rune DSL documentation.*
