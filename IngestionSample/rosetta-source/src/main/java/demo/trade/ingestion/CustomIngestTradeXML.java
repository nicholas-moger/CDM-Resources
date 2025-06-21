package demo.trade.ingestion;

import demo.trade.model.TradeRoot;
import demo.trade.model.Trade;
import demo.trade.model.TradeHeader;
import demo.trade.model.TradeEconomics;
import demo.trade.model.TradeParties;
import demo.trade.model.BuySellEnum;
import demo.trade.model.TradeStatusEnum;
import demo.trade.model.functions.IngestTradeXML;
import com.rosetta.model.lib.records.Date;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Custom implementation of IngestTradeXML that parses XML according to the synonym mappings
 * defined in the demo-trade-ingestion.rosetta file.
 */
public class CustomIngestTradeXML extends IngestTradeXML {

    @Override
    public TradeRoot evaluate(String xmlDocument) {
        // Override the evaluate method to skip validation for demo purposes
        TradeRoot.TradeRootBuilder tradeRootBuilder = doEvaluate(xmlDocument);
        
        if (tradeRootBuilder == null) {
            return null;
        } else {
            return tradeRootBuilder.build();
        }
    }

    @Override
    protected TradeRoot.TradeRootBuilder doEvaluate(String xmlDocument) {
        try {
            // Parse the XML document
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(new ByteArrayInputStream(xmlDocument.getBytes()));
            doc.getDocumentElement().normalize();

            // Extract trade data from XML according to synonym mappings
            Element tradeElement = (Element) doc.getElementsByTagName("trade").item(0);
            if (tradeElement == null) {
                return null;
            }

            // Build the TradeRoot using the parsed XML data
            TradeRoot.TradeRootBuilder tradeRootBuilder = TradeRoot.builder()
                .setTrade(buildTrade(tradeElement));

            return tradeRootBuilder;

        } catch (Exception e) {
            throw new RuntimeException("Failed to parse XML document", e);
        }
    }

    private Trade buildTrade(Element tradeElement) {
        return Trade.builder()
            .setTradeHeader(buildTradeHeader(tradeElement))
            .setTradeEconomics(buildTradeEconomics(tradeElement))
            .setParties(buildTradeParties(tradeElement))
            .build();
    }

    private TradeHeader buildTradeHeader(Element tradeElement) {
        Element headerElement = (Element) tradeElement.getElementsByTagName("header").item(0);
        
        String tradeId = getTextContent(headerElement, "tradeId");
        String tradeDateStr = getTextContent(headerElement, "tradeDate");
        String statusStr = getTextContent(headerElement, "status");

        LocalDate tradeDate = LocalDate.parse(tradeDateStr, DateTimeFormatter.ISO_LOCAL_DATE);
        TradeStatusEnum status = TradeStatusEnum.valueOf(statusStr.toUpperCase());

        return TradeHeader.builder()
            .setTradeId(tradeId)
            .setTradeDate(Date.of(tradeDate.getYear(), tradeDate.getMonthValue(), tradeDate.getDayOfMonth()))
            .setTradeStatus(status)
            .build();
    }

    private TradeEconomics buildTradeEconomics(Element tradeElement) {
        Element economicsElement = (Element) tradeElement.getElementsByTagName("economics").item(0);
        
        String directionStr = getTextContent(economicsElement, "direction");
        String quantityStr = getTextContent(economicsElement, "quantity");
        String priceStr = getTextContent(economicsElement, "price");
        String currency = getTextContent(economicsElement, "currency");
        String notionalStr = getTextContent(economicsElement, "notional");

        BuySellEnum direction = BuySellEnum.valueOf(directionStr.toUpperCase());
        BigDecimal quantity = new BigDecimal(quantityStr);
        BigDecimal price = new BigDecimal(priceStr);
        BigDecimal notional = notionalStr != null ? new BigDecimal(notionalStr) : null;

        return TradeEconomics.builder()
            .setDirection(direction)
            .setQuantity(quantity)
            .setPrice(price)
            .setCurrency(currency)
            .setNotional(notional)
            .build();
    }

    private TradeParties buildTradeParties(Element tradeElement) {
        Element partiesElement = (Element) tradeElement.getElementsByTagName("parties").item(0);
        
        String buyer = getTextContent(partiesElement, "buyer");
        String seller = getTextContent(partiesElement, "seller");
        String broker = getTextContent(partiesElement, "broker");

        return TradeParties.builder()
            .setBuyer(buyer)
            .setSeller(seller)
            .setBroker(broker)
            .build();
    }

    private String getTextContent(Element parent, String tagName) {
        NodeList nodeList = parent.getElementsByTagName(tagName);
        if (nodeList.getLength() > 0) {
            return nodeList.item(0).getTextContent();
        }
        return null;
    }
}
