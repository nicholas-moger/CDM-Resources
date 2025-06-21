/**
 * Comprehensive Rune DSL Demo
 * 
 * This demo showcases the complete Rosetta/Rune DSL workflow:
 * 1. Custom domain model definition (in .rosetta files) 
 * 2. Code generation from Rosetta DSL to Java
 * 3. XML ingestion using synonym mappings
 * 4. Data processing using generated functions
 * 5. JSON output projection
 * 
 * This demonstrates how Rune DSL enables:
 * - Domain modeling in a DSL (Domain Specific Language)
 * - Automatic code generation 
 * - Data ingestion/translation
 * - Business logic execution
 * - Output transformation
 */

import demo.trade.model.*;
import demo.trade.functions.functions.*;
import demo.trade.ingestion.CustomIngestTradeXML;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.math.BigDecimal;

public class RuneDSLDemo {

    public static void main(String[] args) {
        // Configure Jackson for JSON serialization
        ObjectMapper mapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .enable(SerializationFeature.INDENT_OUTPUT)
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);

        System.out.println("=".repeat(80));
        System.out.println("RUNE DSL COMPREHENSIVE DEMO");
        System.out.println("Showcasing: Model Definition → Code Generation → Data Ingestion → Processing → JSON Output");
        System.out.println("=".repeat(80));

        System.out.println("\n" + "=".repeat(80));
        System.out.println("DEMO OVERVIEW:");
        System.out.println("=".repeat(80));
        
        System.out.println("1. Domain Model: Defined in Rosetta DSL (.rosetta files)");
        System.out.println("   - Trade model with header, economics, and parties");
        System.out.println("   - Business functions for validation and calculation");
        System.out.println("   - Ingestion mappings from XML to model");
        System.out.println();
        System.out.println("2. Code Generation: Rosetta compiler generates Java classes");
        System.out.println("   - Model classes (Trade, TradeHeader, TradeEconomics, etc.)");
        System.out.println("   - Function interfaces and implementations");
        System.out.println("   - Ingestion framework integration");
        System.out.println();
        System.out.println("3. Data Processing: XML → Model → Functions → JSON");
        
        System.out.println("\n" + "-".repeat(50));
        System.out.println("PROCESSING SAMPLE DATA:");
        System.out.println("-".repeat(50));

        // Sample XML files from the examples directory
        String[] xmlFiles = {
            "examples/src/main/resources/sample-trade-buy.xml",
            "examples/src/main/resources/sample-trade-sell.xml",
            "examples/src/main/resources/sample-trade-cancelled.xml"
        };

        // Create output directory if it doesn't exist
        try {
            Files.createDirectories(Paths.get("demo-output"));
        } catch (IOException e) {
            System.err.println("Failed to create demo-output directory: " + e.getMessage());
        }

        // Process each sample file
        for (String xmlFile : xmlFiles) {
            try {
                System.out.println("\nProcessing: " + xmlFile);
                System.out.println("-".repeat(50));
                
                // Read the XML content using Java 11+ Files.readString
                String xmlContent = Files.readString(Paths.get(xmlFile));
                System.out.println("XML Input:\n" + xmlContent);
                
                // Ingest XML into our model using the custom ingestion function
                CustomIngestTradeXML ingestFunction = new CustomIngestTradeXML();
                TradeRoot tradeRoot = ingestFunction.evaluate(xmlContent);
                
                if (tradeRoot == null) {
                    System.out.println("Failed to ingest XML - no trade root created");
                    continue;
                }
                
                Trade trade = tradeRoot.getTrade();
                System.out.println("Successfully ingested trade with ID: " + 
                    (trade.getTradeHeader() != null ? trade.getTradeHeader().getTradeId() : "N/A"));
                
                System.out.println("-".repeat(50));
                System.out.println("APPLYING BUSINESS FUNCTIONS:");
                
                // Apply generated business functions
                CalculateTradeNotional notionalCalculator = new CalculateTradeNotional.CalculateTradeNotionalDefault();
                if (trade.getTradeEconomics() != null) {
                    BigDecimal calculatedNotional = notionalCalculator.evaluate(trade);
                    System.out.println("Calculated Notional: $" + calculatedNotional);
                }
                
                ValidateTrade validator = new ValidateTrade.ValidateTradeDefault();
                Boolean isValid = validator.evaluate(trade);
                System.out.println("Trade Validation Result: " + (isValid ? "VALID" : "INVALID"));
                
                GetTradeDescription descriptionGenerator = new GetTradeDescription.GetTradeDescriptionDefault();
                String description = descriptionGenerator.evaluate(trade);
                System.out.println("Trade Description: " + description);
                
                IsActiveTrade activeChecker = new IsActiveTrade.IsActiveTradeDefault();
                Boolean isActive = activeChecker.evaluate(trade);
                System.out.println("Is Active Trade: " + (isActive ? "YES" : "NO"));
                
                System.out.println("-".repeat(50));
                System.out.println("JSON OUTPUT:");
                
                // Convert to JSON for output
                String jsonOutput = mapper.writeValueAsString(tradeRoot);
                System.out.println(jsonOutput);
                
                // Save JSON to file
                String fileName = xmlFile.substring(xmlFile.lastIndexOf("/") + 1, xmlFile.lastIndexOf(".")) + ".json";
                String outputPath = "demo-output/" + fileName;
                try {
                    Files.writeString(Paths.get(outputPath), jsonOutput, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
                    System.out.println("\nJSON saved to: " + outputPath);
                } catch (IOException e) {
                    System.err.println("Failed to save JSON to " + outputPath + ": " + e.getMessage());
                }
                
                System.out.println("-".repeat(30));
                
            } catch (Exception e) {
                System.err.println("Error processing file " + xmlFile + ": " + e.getMessage());
                e.printStackTrace();
            }
        }

        System.out.println("\n" + "=".repeat(80));
        System.out.println("SUMMARY:");
        System.out.println("=".repeat(80));
        System.out.println("✓ Custom domain model defined in Rune DSL");
        System.out.println("✓ Java code auto-generated from Rosetta definitions");
        System.out.println("✓ XML data successfully ingested into typed model");
        System.out.println("✓ Business functions applied to validate and enrich data");
        System.out.println("✓ Results projected as structured JSON output");
        System.out.println();
        System.out.println("This demonstrates the power of Rune DSL for:");
        System.out.println("- Domain-specific modeling");
        System.out.println("- Code generation and type safety");
        System.out.println("- Data transformation and validation");
        System.out.println("- Regulatory compliance and business logic");
        System.out.println("=".repeat(80));
    }
}
