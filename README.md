## Project Overview
Using a set of data from an etsy-style marketplace, this API offers a series of endpoints for data analysis. All endpoints return data compliant to the [JSON API](https://jsonapi.org/) spec.

Timeframe: 6 days   
Contributor: 
- Aliya Merali  
   [Github](https://github.com/aliyamerali) | [LinkedIn](https://www.linkedin.com/in/aliyamerali/)
   
## Built With
- Ruby 2.7.2
- Rails 5.2.6
- ActiveRecord
- SQL
- RSpec
- Factory Bot

## Schema
![rails-engine](https://user-images.githubusercontent.com/5446926/126018393-7985066f-6fc3-49ef-bf21-1a9c81f6f1a4.png)

## Available Endpoints

| Endpoint       | Output       | 
| :------------- |:-------------| 
| GET /api/v1/items?per_page=<results_per_page>&page=<page> | Fetch all Items | 
| GET /api/v1/merchants?per_page=<results_per_page>&page=<page> | Fetch all Merchants | 
| GET /api/v1/items/:id | Fetch a single Item | 
| GET /api/v1/merchants/:id | Fetch a single Merchant | 
| POST /api/v1/items | Create an Item | 
| PATCH /api/v1/items/:id | Update an Item | 
| DELETE /api/v1/items/:id | Destroy an Item | 
| GET /api/v1/merchants/:id/items | Return all items associated with a Merchant |
| GET /api/v1/items/:id/merchant | Return all merchants associated with an item |
| GET /api/vi/merchants/find | Find one merchant by name |
| GET /api/vi/items/find_all | Find all items by name or price range |
| GET /api/v1/revenue/merchants?quantity=<x> | Merchants with Most Revenue | 
| GET /api/v1/merchants/most_items?quantity=<x> | Merchants with Most Items Sold | 
| GET /api/v1/revenue?start_date=<start_date>&end_date=<end_date> | Revenue across Date Range |
| GET /api/v1/revenue/merchants/:id | Total Revenue for a Given Merchant | 
| GET /api/v1/revenue/items?quantity=<x> | Items ranked by Revenue | 
| GET /api/v1/revenue/unshipped?quantity=<x> | Potential revenue of unshipped orders | 
| GET /api/v1/revenue/weekly | Report of revenue by week |

