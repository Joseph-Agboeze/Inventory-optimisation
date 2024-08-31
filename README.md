# Inventory-optimisation:Elevate Customer Satisfaction: Revolutionize Supply Chain with SQL-Driven

## Project Overview
 Unlock the power of Mysql to enhance customer satisfaction within the supply chain domain. 

 ## Business Overview 
 Tech Electro Inc is a prominent player in the consumer electronics manufacturing and distribution sector known for its worldwide recognition and leadership. The company has earned its reputation by offering
 an extensive range of technologically advanced products, ranging from state of the art smartphones to innovative home appliances. This disverse product portfolio showcases Tech ELectro's commitment to meeting the evolving needs of consumers in the tech and electronics industry.
 One of Tech ELectro's distinguishing features is its expansive global presence. Operating in numerous countries, the company has successfully extended its reach to a wide customer base, making it a truly international entity. This global footprint allows Tech Electro Inc to cater to the  diverse preferences and demands of customers in various regions, further solidifying its positions as an industry leader.

 ## Business Problem
 Tech Electro Inc faces a series of intricate inventory management challenges that impede its operational efficiency and customer satisfaction:
1. **Overstocking:** The company frequently finds itself burdened with excessive inventory of certain product, resulting in substantial capital tied up in unsold goods.
2. **Understocking:** Conversely, high-demand products regularly suffer from stockouts, leading to misssed sales opportunities and irate customers unable to access their desired items.
3. **Customer Satisfaction:** These inventory related issues have a direct and deterrmined effect on customer satisfacttion and loyalty. Customers endure delays, frequent stockouts and frustration when they cannot find the products they seek.

## Rationale Of The Project
Inventory Optimization refers to the process of efficiency managing a company's inventory to strike the right balance between supply and demand. The goal is to minimize carrying costs while ensuring that products are readily available to meet customer needs. Transforming customer satisfaction through Mysql powered inventory optimization is a strategic approach that uses SQL(Structured Query Language) and data analysis techniques to enhance customer satisfaction by efficiently managing inventory.

**Importance of MySQL powered Inventory Optimization:**

Implementing a comprehensive inventory optimization system powered by MySQL is imperative for Tech ELectro Inc due to several compelling reasons:
1. **Cost Reduction:** Efficient inventory management through MySQL can significantly reduce carrying costs associated with overstocked items, freeing up capital for strategic investments.
  
2. **Enhanced Customer Satisfaction** By maintaining optimal inventory levels,Tech ELectro Inc ensures that its products are readily available, elevating the overall customer experience and fostering loyalty.
  
3. **Competitive Advantage:** Streamlined inventory management empoowers Tech Electro Inc to respond swiftly to market fluctuations and shifting customer demands, providing a competitive edge.

4. **Profitability:** Improved inventory control throuugh MySQL optimization leads to reduced waste and improved cash flow, directly impacting profitability.

## Aim of Projects
The primary objectives of this projects are to implement a sophisticated inventory optimization system utilizing MySQL and address the identified business challenges effectivel. The project aims to achieve the following:
- **Optimal Inventory Levels:** Utilize MySQL optimization techniques to determine the optimal stock levels for each products SKU, thereby minimizing overstock and understock situations.

- **Data-Driven Decisions:** Enable data-driven decision making in inventory management by leveraging MySQL analystics to reduce potential costs and enhance customer satisfaction.

## Data Analytics Project Scope 
  **Exploratory Data Analysis (EDA)**
  Leveraging MySQL for EDA, conducting advanced analytics and statistical analysis to explore data pattern, correlations and descriptive statistica without relying on data visualization.
  
  **Optimal Inventory Levels**
  Utilize MySQL optimization techniques and algorithms to determine optimal inventory levels for each products SKU.

  **Documentation annd Recommendation**
  Develop comprehensive documentationn of the projects encompassing MySQL scripts, methodologies and user guide.

## Data Exploration 
###### This is a visual exploration of the datasets to understand its distribution


https://github.com/user-attachments/assets/2a49a852-a52f-4d8f-9bcf-6848ebff9e04


## Data Cleaning
###### Changing the datasets to its right data types
###### EXTERNAL_FACTORS TABLE 

 **SalesData DATE**,
```MySQL
 ALTER TABLE external_factors
ADD COLUMN New_SalesDate DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE external_factors
SET New_SalesDate = STR_TO_DATE(SalesDate, "%d/%m/%Y");
ALTER TABLE external_factors
DROP COLUMN SalesDate;
ALTER TABLE external_factors
CHANGE COLUMN New_SalesDate SalesDate DATE;
```

 **GDP DECIMAL(10,2),**
```MySQL
ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL(10,2);
```

  **InflationRate DECIMAL(5,2),**
  ```MySQL
ALTER TABLE external_factors
MODIFY COLUMN Inflation_Rate DECIMAL(5,2);
```

 **SeasonalFactor DECIMAL (5,2)**
 ```MySQL
ALTER TABLE external_factors
MODIFY COLUMN Seasonal_Factor DECIMAL(5,2);
```
###### PRODUCT_INFORMATION TABLE

**PRODUCT_ID INT NOT NULL,**  

**PRODUCT_CATERGORY VARCHAR(20),**

**PROMOTIONS ENUM("YES",NO)**
```MySQL
ALTER TABLE product_information
MODIFY COLUMN Product_Category VARCHAR(20);

ALTER TABLE product_information
ADD COLUMN New_Promotions ENUM("Yes","No");
UPDATE product_information
SET New_Promotions = CASE
WHEN Promotions = "Yes" THEN "Yes"
WHEN Promotions = "No" THEN "No"
ELSE NULL
END;
ALTER TABLE product_information
DROP COLUMN Promotions;
ALTER TABLE product_information
CHANGE COLUMN New_Promotions Promotions ENUM("Yes","No");
```
## SALES_DATA TABLE
**Product_ID INT NOT NULL**

**Sales_Date DATE**
```MySQL
ALTER TABLE sales_data
ADD COLUMN New_Sales_Date DATE;
SET SQL_SAFE_UPDATES = 0;
UPDATE sales_data
SET New_Sales_Date = STR_TO_DATE(Sales_Date, "%d/%m/%Y");
ALTER TABLE sales_data
DROP COLUMN Sales_Date;
ALTER TABLE sales_data
CHANGE COLUMN New_Sales_Date Sales_Date DATE;
```
**Inventory_Quantity INT**

**Product_Cost DECIMAL (15,2)**
```MySQL
ALTER TABLE sales_data
MODIFY COLUMN Product_Cost DECIMAL(15,2);
 ```



































































  






  ## FEEDBACK LOOPS
 ### Feedback Loop Establishment:
- Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
- Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
- System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.
- Refinement Based on Feedback:
- Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
- Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
- Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.

## INSIGHTS
### Inventory Discrepancies
- The initial stages of the analysis revealed significant discrepancies in inventory levels, with instances of overstocking. These inconsistencies were contributing to customer capital inefficiencies and dissatisfaction.
### Sales Trends and External Influences
- The analysis indicated that sales trends were notably influenced by various external factors. Recognizing these patterns presents an opportunity to forecast demand more accurately.
### Suboptimal Inventory Levels
- Through the inventory optimization analysis, it was evident that the existing inventory levels were not optimized for current sales trends. Products were identified that had either close excess inventory.

## RECOMMEDATIONS
1. Implement Dynamic Inventory Management: The company should transition from a static to a dynamic management system, adjusting inventory levels based on real-time sales trends, seasonality, and external factors.
2. Optimize Reorder Points and Safety Stocks: Use the reorder points and safety stocks calculated during the analysis to minimize stockouts and reduce excess inventory. Regularly review these metrics to ensure they align with current market conditions.
3. Enhance Pricing Strategies: Conduct a thorough review of product pricing strategies, especially for products identified as unprofitable. Consider factors such as competitor pricing, market demand, and product acquisition costs.
4. Reduce Overstock: Identify products that are consistently overstocked and take steps to reduce their inventory levels. This could include promotional sales, discounts, or even discontinuing products with low sales performance.
5. Establish a Feedback Loop: Develop a systematic approach to collect and analyze feedback from various stakeholders. Use this feedback for continuous improvement and alignment with business objectives.
6. Regular Monitoring and Adjustments: Adopt a proactive approach to inventory management by regularly monitoring key metrics and making necessary adjustments to inventory levels, order quantities, and safety stocks.


  









   
